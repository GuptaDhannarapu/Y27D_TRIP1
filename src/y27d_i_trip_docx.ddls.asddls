@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Attachements'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Y27D_I_TRIP_DOCX as select from y27d_t_pax_docx
association to parent Y27D_I_TRIP_PAX as _PlaPax on $projection.Batchid = _PlaPax.Batchid and
                                                    $projection.Counter = _PlaPax.Counter
association to Y27D_I_TRIP_PLAN as _plaMain on $projection.Batchid = _plaMain.Batch_Id
{
    key batchid as Batchid,
    key counter as Counter,
    key attch_id as AttchId,
    @Semantics.largeObject:{
            mimeType: 'Mimetype',
            fileName: 'Filename',
            contentDispositionPreference: #ATTACHMENT
      }
    document as Document,
    @Semantics.mimeType: true
    mimetype as Mimetype,
    filename as Filename,
    comments as Comments,
    
    _PlaPax,
    _plaMain
}
