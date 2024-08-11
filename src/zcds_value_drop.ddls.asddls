@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Value Drop'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZCDS_VALUE_DROP as select from I_Currency
association [0..*] to I_CurrencyText as _Text 
    on $projection.Currency = _Text.Currency and
       $projection.language = $session.system_language
{
@Search.defaultSearchElement: true
@ObjectModel.text.element: [ '_Text.CurrencyName' ]
    key Currency,
//    _Text.CurrencyName,
    _Text.CurrencyShortName,
    _Text.Language,
//    Decimals,
//    CurrencyISOCode,
//    AlternativeCurrencyKey,
//    IsPrimaryCurrencyForISOCrcy,
    /* Associations */
    _Text
}
//where _Text.Language = 'E'
