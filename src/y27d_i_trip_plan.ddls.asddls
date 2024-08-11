@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Trip Details'
define root view entity Y27D_I_TRIP_PLAN
  as select from y27d_t_plan_det
  //association to Y27D_I_TRIP_PAX as _paxDet on $projection.Batch_Id =
  composition [0..*] of Y27D_I_TRIP_ACT as _plaAct
  composition [0..*] of Y27D_I_TRIP_PAX as _paxDet 
  
{
  key batchid  as Batch_Id,
      place    as Place,
      frdate   as From_date,
      todate   as To_date,
      @Semantics.amount.currencyCode: 'Currency'
      expend   as Expend,
      currency as Currency,
      totalpax as Total_per,
      status   as Status,
      @Semantics.user.createdBy: true
      created_by as Created_by,
      case status
          when ' ' then 2
          when 'X' then 3
          else 1
      end      as Status_msg,
      case status
          when ' ' then 'Yet to confirm'
          when 'X' then 'Confirmed'
          else 'Pending'
      end      as Comments,
      //    _association_name // Make association public
      _paxDet,
      _plaAct
}
