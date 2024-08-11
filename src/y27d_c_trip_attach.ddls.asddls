@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Attachements'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity Y27D_C_TRIP_ATTACH
  provider contract transactional_query as projection on Y27D_I_TRIP_ATTACH
{
    key Batchid,
    key Counter,
    key AttchId,
    Attachment,
    MimeType,
    Filename,
    Comments
}
