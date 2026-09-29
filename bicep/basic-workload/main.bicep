@description('배포 지역')
param location string = resourceGroup().location

@description('가상 머신 이름')
param vmName string = 'myBasicVM'

@description('관리자 사용자 이름')
param adminUsername string = 'azureuser'

@description('관리자 비밀번호 또는 SSH 공개 키')
@secure()
param adminPasswordOrKey string

// 1. 가상 네트워크(VNet) 및 서브넷 정의
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'myVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'mySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// 2. 네트워크 인터페이스(NIC) 정의
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// 3. 가상 머신(VM) 정의 (Ubuntu Linux 기준)
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s' // 비용이 저렴한 기본형(B-Series) 사이즈
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
