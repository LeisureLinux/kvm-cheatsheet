


# virsh autostart --disable TestServer
Domain TestServer unmarked as autostarted


https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-virtualization-tips_and_tricks-disable_smart_disk_monitoring_for_guests

SMART disk monitoring can be safely disabled as virtual disks and the physical storage devices are managed by the host physical machine. 


https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/chap-guest_virtual_machine_device_configuration
保存当前运行状态的虚拟机 XML
 # virsh save-image-edit guestVM.xml --running 


设备控制器的类型：
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-guest_virtual_machine_device_configuration-configuring_device_controllers
    ide
    fdc
    scsi
	scsi 下可以包含的 model:
		     auto
		    buslogic
		    ibmvscsi
		    lsilogic
		    lsisas1068
		    lsisas1078
		    virtio-scsi
		    vmpvscsi 
    sata
    usb
	usb 下可以包含的 model:
		
        	piix3-uhci
    		piix4-uhci
    		ehci
    		ich9-ehci1
    		ich9-uhci1
    		ich9-uhci2
    		ich9-uhci3
    		vt82c686b-uhci
    		pci-ohci
    		nec-xhci 
	
    ccid
    virtio-serial
    pci 
	pci 包含如下 model:
    		pci-root
    		pcie-root
    		pci-bridge
    		dmi-to-pci-bridge 


