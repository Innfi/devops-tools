targetScope = 'subscription'

import { builtInRoles } from './roles.bicep'

@description('msp offer name')
param mspOfferName string = 'Readonly Monitoring'

@description('description')
param mspOfferDescription string = 'Inventory and alert collection. Read-only access only.'

@description('manager tenant ID (GUID)')
@minLength(36)
@maxLength(36)
param managedByTenantId string

@description('security group objectId')
param collectorGroupId string

@description('operator group objectId')
param opsGroupId string

var authorizations = [
  {
    principalId: collectorGroupId
    principalIdDisplayName: 'SRE Collector - Reader'
    roleDefinitionId: builtInRoles.reader
  }
  {
    principalId: collectorGroupId
    principalIdDisplayName: 'SRE Collector - Monitoring Reader'
    roleDefinitionId: builtInRoles.monitoringReader
  }
  {
    principalId: opsGroupId
    principalIdDisplayName: 'SRE Ops - Delegation Cleanup'
    roleDefinitionId: builtInRoles.delegationDelete
  }
]

var registrationName = guid(mspOfferName)
var assignmentName = guid(mspOfferName, subscription().subscriptionId)

resource registrationDefinition 'Microsoft.ManagedServices/registrationDefinitions@2022-10-01' = {
  name: registrationName
  properties: {
    registrationDefinitionName: mspOfferName
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
  }
}

resource registrationAssignment 'Microsoft.ManagedServices/registrationAssignments@2022-10-01' = {
  name: assignmentName
  properties: {
    registrationDefinitionId: registrationDefinition.id
  }
}

output delegatedSubscriptionId string = subscription().subscriptionId
output offerName string = mspOfferName
output authorizationCount int = length(authorizations)
