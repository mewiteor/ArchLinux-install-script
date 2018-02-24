#!/bin/sh

# Send the header so that i3bar knows we want to use JSON:
echo '{"version":1}'

# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[],'

# Now send blocks with information forever:
case $1 in
    'up')
        exec conky -c $HOME/.config/conky/conky-up.conf &
        ;;
    'down')
        exec conky -c $HOME/.config/conky/conky-down.conf &
        ;;
esac

rm -f /tmp/debug.in
while true; do
    read XX
    echo $XX>>/tmp/debug.in
done
