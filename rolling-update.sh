#! /bin/bash

set -eu

CTRL_BASENAME=railscontroller
TARGET_COUNT=2
GKE_CMD="gcloud preview container"
CTRL_CMD="$GKE_CMD replicationcontrollers"
POD_CMD="$GKE_CMD pods"

# Some minimal protection against racy deploys
if [ $($CTRL_CMD list | grep -c $CTRL_BASENAME) -ne 1 ]; then
    echo "More than one replication controller deployed"
    exit 1
fi

OLD_CTRL_VERSION=$($CTRL_CMD list | grep $CTRL_BASENAME | cut -f1 -d ' ' | sed "s/$CTRL_BASENAME-//")
NEW_CTRL_VERSION=$CIRCLE_SHA1

if [ $OLD_CTRL_VERSION == $NEW_CTRL_VERSION ]; then
    echo "$NEW_CTRL_VERSION is already deployed"
    exit 1
fi

echo "Old version:" $OLD_CTRL_VERSION
echo "New version:" $NEW_CTRL_VERSION

# Assumes CTRL_VERSION
count-running() {
    echo $($POD_CMD list | grep -c "$CTRL_VERSION.*Pending") #TODO: Change to running
}

# Assumes CTRL_VERSION
delete-controller() {
    $CTRL_CMD delete $CTRL_BASENAME-$CTRL_VERSION > /dev/null
    
}

# Assumes CTRL_COUNT and CTRL_VERSION
create-controller() {
    CTRL_ID="$CTRL_BASENAME-$CTRL_VERSION" \
	envsubst < kubernetes/rails-controller.json.template > rails-controller.json
    $CTRL_CMD create --config-file rails-controller.json > /dev/null
}

# Assumes CTRL_COUNT, and CTRL_VERSION
update-controller() {
    delete-controller
    create-controller
}


echo "Bringing up new pods..."
CTRL_COUNT=$TARGET_COUNT CTRL_VERSION=$NEW_CTRL_VERSION create-controller

ACTUAL_COUNT=0
for i in {1..5}; do
    ACTUAL_COUNT=$(CTRL_VERSION=$NEW_CTRL_VERSION count-running)
    if [ $ACTUAL_COUNT -eq $TARGET_COUNT ]; then
	break
    fi
    sleep 5
done

if [ $ACTUAL_COUNT -ne $TARGET_COUNT ]; then
    echo "Timed out waiting for new pods"
    exit 1
fi

echo "Shutting down old pods..."
CTRL_COUNT=0 CTRL_VERSION=$OLD_CTRL_VERSION update-controller


ACTUAL_COUNT=$TARGET_COUNT
for i in {1..5}; do
    ACTUAL_COUNT=$(CTRL_VERSION=$OLD_CTRL_VERSION count-running)
    if [ $ACTUAL_COUNT -eq 0 ]; then
	break
    fi
    sleep 5
done

if [ $ACTUAL_COUNT -ne 0 ]; then
    echo "Timed out shutting down old pods"
    exit 1
fi

CTRL_VERSION=$OLD_CTRL_VERSION delete-controller
