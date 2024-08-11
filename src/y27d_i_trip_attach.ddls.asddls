@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachement of Proof'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity Y27D_I_TRIP_ATTACH as select from y27d_t_attach
{
    key batchid as Batchid,
    key counter as Counter,
    key attch_id as AttchId,
     @Semantics.largeObject:
      { mimeType: 'MimeType',
      fileName: 'Filename',
      contentDispositionPreference: #INLINE }
//      @EndUserText.label: 'attachement'
      document            as Attachment,
      @Semantics.mimeType: true
      mimetype              as MimeType,
      filename              as Filename,
      comments              as Comments
}
