@EndUserText.label: 'Consumption View for Attachements'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Y27D_C_TRIP_DOCX as projection on Y27D_I_TRIP_DOCX
{
    key Batchid,
    key Counter,
    key AttchId,
    Document,
    Mimetype,
    Filename,
    Comments,
    /* Associations */
    _plaMain: redirected to Y27D_C_TRIP_PLAN,
    _PlaPax: redirected to parent Y27D_C_TRIP_PAX
}
