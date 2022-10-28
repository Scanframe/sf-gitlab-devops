#!/bin/bash
#set -x

# Find the VM id by executing command 'VBoxManage list -s vms'
VM_ID='{40a85ff3-a305-4b21-b050-6a1504bd5403}'

case "$1" in

	start)
 	VBoxManage startvm ${VM_ID} --type headless
	;;

	down)
 	# pause|resume|reset|poweroff|savestate|acpipowerbutton
	VBoxManage controlvm ${VM_ID} acpipowerbutton
	;;
	
	off)
	VBoxManage controlvm ${VM_ID} poweroff
	;;
	
	*)
	echo "Usage: $0 <start|down|off>"
	exit 1

esac