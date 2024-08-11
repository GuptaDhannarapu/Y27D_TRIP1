@EndUserText.label: 'Table Maintenance Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Y27D_C_TRIP_TMG_1 as projection on Y27D_I_TRIP_TMG_1
{
    key Batchid,
    SingletonID,
    Place,
    Frdate,
    Todate,
    Expend,
    Currency,
    Totalpax,
    Status,
    LocalCreatedBy,
    LastChangedAt,
    Configdeprecationcode,
    /* Associations */
    _Singleton : redirected to parent Y27D_C_TRIP_SINGLE1
}
