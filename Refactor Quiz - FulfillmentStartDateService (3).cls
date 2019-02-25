public with sharing class FulfillmentStartDateService {
	/*

	   CodeScan reports this file has too many methods, cyclomatic complexity of 3 and too many fields

	   How do you refactor this code to fix those issues?

	  The configuration for the validation check is in Custom Metadata Types
	  (Setup->Develop->Custom Metadata Types->Configuration Setting->Manage Configuration Setting)
	  The error messages are setup in Custom Labels
	 */
	static final Integer BATCH_SIZE = 90;
	private FLIDateValidation.IFLIStartDateAggregation service;
	private List<Fulfillment_Line_Item__c> flisToValidateStartDateOverlapOnNew;
	private List<Fulfillment_Line_Item__c> flisToValidateStartDateOverlapOnUpdate;
	private List<Fulfillment_Line_Item__c> flisToValidateStartDateForActive;
	private List<Fulfillment_Line_Item__c> flisToValidateDatesForDrops;
	private List<Fulfillment_Line_Item__c> flisToValidateDatesForSuspended;
	private List<Fulfillment_Line_Item__c> flisToValidateDatesForExpire;
	private List<Fulfillment_Line_Item__c> flisToValidateDatesForInvalidStatus;
	private List<Fulfillment_Line_Item__c> flisToValidateDatesForPendingActivation;
	private List<Fulfillment_Line_Item__c> flisToValidateDropDateForDrops;
	private List<Fulfillment_Line_Item__c> flisToValidateDropDateWithEndDate;


	private boolean checkStartDateOverlapOnNew {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Start_Date_Overlap_On_New')); }
	}

	private boolean checkStartDateOverlapOnUpdate {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Start_Date_Overlap_On_Update')); }
	}

	private boolean checkStartDateForActive {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Start_Date_For_Active')); }
	}

	private boolean checkDatesForDrops {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Dates_For_Drops')); }
	}

	private boolean checkDatesForSuspended {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Dates_For_Suspended')); }
	}

	private boolean checkDatesForExpire {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Dates_For_Expire')); }
	}

	private boolean checkDatesForInvalidStatus {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Dates_For_Invalid_Status')); }
	}

	private boolean checkDatesForPendingActivation {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Dates_For_Pending_Activation')); }
	}

	private boolean checkDropDateForDrops {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Drop_Date_For_Drops')); }
	}

	private boolean checkDropDateWithEndDate {
		get { return Boolean.valueOf(ConfigSetting.getValue('FLI_Check_Drop_Date_With_End_Date')); }
	}

	public FulfillmentStartDateService(FLIDateValidation.IFLIStartDateAggregation service,
	                                   List<Fulfillment_Line_Item__c> newRecords,
	                                   Map<Id, sObject> oldMap) {
		this.service = service;
		filterFlisToValidate(newRecords, oldMap);
	}

	private void filterFlisToValidate(List<Fulfillment_Line_Item__c> newRecords, Map<Id, sObject> oldMap) {
		List<Fulfillment_Line_Item__c> validateStartDateOverlapOnNew = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateStartDateOverlapOnUpdate = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateStartDateForActive = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDatesForDrops = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDatesForSuspended = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDatesForExpire = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDatesForInvalidStatus = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDatesForPendingActivation = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDropDateForDrops = new List<Fulfillment_Line_Item__c> ();
		List<Fulfillment_Line_Item__c> validateDropDateWithEndDate = new List<Fulfillment_Line_Item__c> ();

		for (Fulfillment_Line_Item__c fli : newRecords) {
			Fulfillment_Line_Item__c oFli = oldMap == null ? null : (Fulfillment_Line_Item__c) oldMap.get(fli.Id);

			if (hasDropDateForDrop(checkDropDateForDrops, fli, oFli)) {
				validateDropDateForDrops.add(fli);
			}

			if (hasDropDateWithEndDate(checkDropDateWithEndDate, fli, oFli)) {
				validateDropDateWithEndDate.add(fli);
			}

			if (oFli == null && checkStartDateOverlapOnNew) {
				//if (checkStartDateOverlapOnNew) {
					validateStartDateOverlapOnNew.add(fli);
				//}
			}
			if (oFli != null) {
				if (hasStartDateOverlapOnUpdate(checkStartDateOverlapOnUpdate, fli, oFli)) {
					validateStartDateOverlapOnUpdate.add(fli);
				}

				if (hasStartDateForActive(checkStartDateForActive, fli, oFli)) {
					validateStartDateForActive.add(fli);
				}

				if (hasDatesForDrops(checkDatesForDrops, fli, oFli)) {
					validateDatesForDrops.add(fli);
				}

				if (hasDatesForSuspended(checkDatesForSuspended, fli, oFli)) {
					validateDatesForSuspended.add(fli);
				}

				if (hasDatesForExpire(checkDatesForExpire, fli, oFli)) {
					validateDatesForExpire.add(fli);
				}

				if (hasDatesForInvalidStatus(checkDatesForInvalidStatus, fli, oFli)) {
					validateDatesForInvalidStatus.add(fli);
				}

				if (hascheckDatesForPendingActivation(checkDatesForPendingActivation, fli, oFli)) {
					validateDatesForPendingActivation.add(fli);
				}
			}

			this.flisToValidateStartDateOverlapOnNew = validateStartDateOverlapOnNew;
			this.flisToValidateStartDateOverlapOnUpdate = validateStartDateOverlapOnUpdate;
			this.flisToValidateStartDateForActive = validateStartDateForActive;
			/this.flisToValidateDatesForDrops = validateDatesForDrops;
			this.flisToValidateDatesForSuspended = validateDatesForSuspended;
			this.flisToValidateDatesForExpire = validateDatesForExpire;
			this.flisToValidateDatesForInvalidStatus = validateDatesForInvalidStatus;
			this.flisToValidateDatesForPendingActivation = validateDatesForPendingActivation;
			this.flisToValidateDropDateForDrops = validateDropDateForDrops;
			this.flisToValidateDropDateWithEndDate = validateDropDateWithEndDate;
		}
	}

	private static boolean hasStartDateOverlapOnUpdate(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && newFli.StartDate__c != oldFli.StartDate__c && newFli.Contract_Line_Item__c != null);
	}

	private static boolean hasStartDateForActive(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && oldFli.Status__c == 'Active' && newfli.StartDate__c != oldFli.StartDate__c);
	}

	private static boolean hasDatesForDrops(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && (oldFli.StartDate__c != newFli.StartDate__c ||
		(oldFli.DropDate__c != newFli.DropDate__c &&
		 oldFli.DropDate__c != null && newFli.DropDate__c != null) ||
		                       oldFli.Projected_End_Date__c != newFli.Projected_End_Date__c) &&
		(oldFli.Status__c == 'Dropped' || oldFli.Status__c == 'Drop Requested'));
	}

	private static boolean hasDatesForSuspended(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && (oldFli.StartDate__c != newFli.StartDate__c ||
		                       oldFli.Suspension_Date__c != newFli.Suspension_Date__c ||
		                       oldFli.Projected_End_Date__c != newFli.Projected_End_Date__c) &&
		(oldFli.Status__c == 'Suspended'));
	}

	private static boolean hasDatesForExpire(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && (oldFli.StartDate__c != newFli.StartDate__c ||
		                       oldFli.Projected_End_Date__c != newFli.Projected_End_Date__c) &&
		(oldFli.Status__c == 'Expire'));
	}

	private static boolean hasDatesForInvalidStatus(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && oldFli.DropDate__c != newFli.DropDate__c &&
		       newFli.StartDate__c == null && oldFli.Status__c == 'Invalid Status');
	}

	private static boolean hascheckDatesForPendingActivation(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		return(configValue && newFli.Contract_Line_Item__c != null &&
		       oldFli.StartDate__c != newFli.StartDate__c && oldFli.StartDate__c != null &&
		       newFli.Status__c == 'Pending Activation');
	}

	private static boolean hasDropDateForDrop(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		boolean retValue;
		if (oldFli == null) { //insert fli
			retValue = configValue && newFli.DropDate__c == null;
		} else { //update fli
			retValue = configValue && (oldFli.DropDate__c != null && newFli.DropDate__c == null)
			&& (oldFli.Status__c == 'Dropped' || oldFli.Status__c == 'Drop Requested');
		}
		return retValue;
	}

	private static boolean hasDropDateWithEndDate(boolean configValue, Fulfillment_Line_Item__c newFli, Fulfillment_Line_Item__c oldFli) {
		boolean retValue;
		if (oldFli == null) { //insert fli
			retValue = configValue && newFli.DropDate__c > newFli.Effective_Drop_Date__c;
		} else { //update fli
			retValue = configValue && (oldFli.DropDate__c == null && newFli.DropDate__c != null)
			&& (newFli.DropDate__c > oldFli.Effective_Drop_Date__c);
		}
		return retValue;
	}

	public void execute() {
		if (!flisToValidateStartDateOverlapOnNew.isEmpty()) {
			validateStartDateOverlapOnNew();
		}

		if (!flisToValidateStartDateForActive.isEmpty()) {
			validateStartDateForActive();
		}

		if (!flisToValidateDatesForDrops.isEmpty()) {
			validateDateForDrops();
		}

		if (!flisToValidateDatesForSuspended.isEmpty()) {
			validateDateForSuspended();
		}

		if (!flisToValidateDatesForExpire.isEmpty()) {
			validateDateForExpire();
		}

		if (!flisToValidateDatesForInvalidStatus.isEmpty()) {
			validateDateForInvalidStatus();
		}

		if (!flisToValidateDatesForPendingActivation.isEmpty()) {
			validateDateForPendingActivation();
		}

		if (!flisToValidateStartDateOverlapOnUpdate.isEmpty()) {
			validateStartDateOverlapOnUpdate();
		}


		if (!flisToValidateDropDateForDrops.isEmpty()) {
			validateDropDateForDrops();
		}

		if (!flisToValidateDropDateWithEndDate.isEmpty()) {
			validateDropDateWithEndDate();
		}
	}

	private void validateStartDateOverlapOnNew() {
		Set<Id> cliIds = new Set<Id> ();
		for (Fulfillment_Line_Item__c fli : flisToValidateStartDateOverlapOnNew) {
			if (fli.Contract_Line_Item__c != null) {
				cliIds.add(fli.Contract_Line_Item__c);
			}
		}
		Map<Id, Contract_Line_Item__c> clisMap = new Map<Id, Contract_Line_Item__c> ([SELECT Id, Name, Max_End_Date__c
		                                                                             FROM Contract_Line_Item__c WHERE Id IN :cliIds]);

		for (Fulfillment_Line_Item__c fli : flisToValidateStartDateOverlapOnNew) {
			Contract_Line_Item__c cli = clisMap.get(fli.Contract_Line_Item__c);
			if (cli != null && cli.Max_End_Date__c != null && fli.StartDate__c <= cli.Max_End_Date__c) {
				fli.addError(Label.Fulfillment_Start_Date_For_New_Validation_Error_Message); //You cannot create fulfillment line item with an overlapping start date *
			}
		}
	}

	private void validateStartDateOverlapOnUpdate() {
		checkBatchSize();
		List<FulfillmentStartDateService.AggregateDataObject> results = service.loadData();
		Map<Id, Date> mapCliIdWithMaxEndDate = new Map<Id, Date> ();
		Map<Id, Date> mapCliIdWithMaxCreatedDate = new Map<Id, Date> ();

		for (FulfillmentStartDateService.AggregateDataObject result : results) {
			mapCliIdWithMaxEndDate.put(result.ContractLineItemId, result.MaxEndDate);
			mapCliIdWithMaxCreatedDate.put(result.ContractLineItemId, result.MaxCreatedDate);
		}

		for (Fulfillment_Line_Item__c fli : flisToValidateStartDateOverlapOnUpdate) {

			Date maxEndDate = mapCliIDWithMaxEndDate.get(fli.Contract_Line_Item__c);
			Date maxCreatedDate = mapCliIDWithMaxCreatedDate.get(fli.Contract_Line_Item__c);
			System.debug('***logging*** fli: ' + fli);
			System.debug('***logging*** maxEndDate: ' + maxEndDate);
			System.debug('***logging*** maxCreatedDate: ' + maxCreatedDate);
			if (fli.CreatedDate<maxCreatedDate) {
				fli.addError(Label.Fulfillment_Update_Latest_Start_Date);
				continue;
			}

			if (fli.StartDate__c <= maxEndDate) {
				fli.addError(Label.Fulfillment_Start_Date_For_Update_Validation_Error_Message);
			}

		}
	}

	private void validateStartDateForActive() {
		for (Fulfillment_Line_Item__c fli : flisToValidateStartDateForActive) {
			fli.addError(Label.Fulfillment_Update_Start_Date_For_Active); //You cannot change the start date for active fulfillment 
		}
	}

	private void validateDateForDrops() {
		for (Fulfillment_Line_Item__c fli : flisToValidateDatesForDrops) {
			fli.addError(Label.Fulfillment_Dates_For_Drops); //You cannot change start date, drop date and projected end date when fulfillment line item is Dropped or Drop Requested *
		}
	}

	private void validateDateForSuspended() {
		for (Fulfillment_Line_Item__c fli : flisToValidateDatesForSuspended) {
			fli.addError(Label.Fulfillment_Dates_For_Suspended); //You cannot change start date, suspend date and projected end date when fulfillment line item is Suspended *
		}
	}

	private void validateDateForExpire() {
		for (Fulfillment_Line_Item__c fli : flisToValidateDatesForExpire) {
			if (fli.EndDate__c != null && fli.DropDate__c != fli.EndDate__c + 1) {
				fli.addError(Label.Fulfillment_Dates_For_Expire); //You cannot change start date, projected end date. Drop date cannot be other that End Date + 1, for Expired fulfillment *
			}
		}
	}

	private void validateDateForInvalidStatus() {
		for (Fulfillment_Line_Item__c fli : flisToValidateDatesForInvalidStatus) {
			fli.addError(Label.Fulfillment_Dates_For_Invalid_Status); //You cannot update the Drop date when there is no start date for the fulfillment *
		}
	}

	private void validateDateForPendingActivation() {
		Set<Id> cliIds = new Set<Id> ();
		for (Fulfillment_Line_Item__c fli : flisToValidateDatesForPendingActivation) {
			if (fli.Contract_Line_Item__c != null) {
				cliIds.add(fli.Contract_Line_Item__c);
			}
		}
		Map<Id, Contract_Line_Item__c> clisMap = new Map<Id, Contract_Line_Item__c> ([SELECT Id, Name, FLI_Count__c
		                                                                             FROM Contract_Line_Item__c WHERE Id IN :cliIds]);

		for (Fulfillment_Line_Item__c fli : flisToValidateDatesForPendingActivation) {
			Contract_Line_Item__c cli = clisMap.get(fli.Contract_Line_Item__c);
			if (cli.FLI_Count__c> 1) {
				fli.addError(Label.Fulfillment_Dates_For_Pending_Activation); //You cannot change the start date for Pending Activation when there are other fulfillments *
			}
		}
	}

	private void validateDropDateForDrops() {
		Set<Id> cliIds = new Set<Id> ();
		for (Fulfillment_Line_Item__c fli : flisToValidateDropDateForDrops) {
			if (fli.Contract_Line_Item__c != null) {
				cliIds.add(fli.Contract_Line_Item__c);
			}
		}
		Map<Id, Contract_Line_Item__c> clisMap = new Map<Id, Contract_Line_Item__c> ([SELECT Id, Name, Max_Drop_Date__c, Max_Fulfillment_Start_Date__c
		                                                                             FROM Contract_Line_Item__c WHERE Id IN :cliIds]);

		for (Fulfillment_Line_Item__c fli : flisToValidateDropDateForDrops) {
			Contract_Line_Item__c cli = clisMap.get(fli.Contract_Line_Item__c);
			if (cli != null && cli.Max_Drop_Date__c != null
			    && cli.Max_Fulfillment_Start_Date__c != null
			    && (fli.DropDate__c<cli.Max_Drop_Date__c || fli.StartDate__c<cli.Max_Fulfillment_Start_Date__c)
			) {
				fli.addError(Label.Fulfillment_Drop_Date_For_Drops); //You cannot remove drop date value when drop date is not max drop date for the fli's cli, or start date is not max start date for the fli's cli *
			}
		}
	}

	private void validateDropDateWithEndDate() {
		for (Fulfillment_Line_Item__c fli : flisToValidateDropDateWithEndDate) {
			fli.addError(Label.Fulfillment_Drop_Date_With_End_Date); //You cannot make the drop date to be greater than the end date *
		}
	}

	private void checkBatchSize() {
		if (flisToValidateStartDateOverlapOnUpdate.size()> BATCH_SIZE) {
			throw new InvalidBatchSizeException(Label.Fulfillment_Update_Batch_Size);
		}
	}

	public class InvalidBatchSizeException extends Exception { }

	public class FLIStartDateAggreagation implements IFLIStartDateAggregation {

		List<Fulfillment_Line_Item__c> fliList;
		String soqlStatement;

		public FLIStartDateAggreagation(List<Fulfillment_Line_Item__c> fliList) {
			this.fliList = fliList;
		}

		public List<FulfillmentStartDateService.AggregateDataObject> loadData() {

			buildSoql();
			List<FulfillmentStartDateService.AggregateDataObject> fliResults = new List<FulfillmentStartDateService.AggregateDataObject> ();
			System.debug('*** logging soqlStatement1 ***' + soqlStatement);
			if (soqlStatement != null && soqlStatement != '') {
				for (AggregateResult ar : Database.Query(soqlStatement)) {
					FulfillmentStartDateService.AggregateDataObject aggdata = new FulfillmentStartDateService.AggregateDataObject();
					aggdata.contractLineItemId = String.valueOf(ar.get('Contract_Line_Item__c'));
					aggdata.maxEndDate = Date.valueOf(ar.get('MaxEndDate'));
					aggdata.maxCreatedDate = Date.valueOf(ar.get('MaxCreatedDate'));
					fliResults.add(aggdata);
				}
			}
			return fliResults;
		}

		private void buildSoql() {
			String fliIds;
			String cliIds;

			fliIds = '';
			cliIds = '';
			for (Fulfillment_Line_Item__c f : fliList) {
				fliIds += '\'' + f.Id + '\', ';
				cliIds += '\'' + f.Contract_Line_Item__c + '\', ';

			}
			if (fliIds.length()> 2) {
				fliIds = fliIds.substring(0, fliIds.length() - 2);
			}
			if (cliIds.length() > 2) {
				cliIds = cliIds.substring(0, cliIds.length() - 2);
			}

			if (fliIds.length() > 0 && cliIds.length() > 0) {
				System.debug('***logging fliIds****' + fliIds);
				soqlStatement = 'SELECT MAX(EndDate__c) MaxEndDate, MAX(CreatedDate) MaxCreatedDate, Contract_Line_Item__c  FROM Fulfillment_Line_Item__c WHERE Id Not IN (' + fliIds + ') AND Contract_Line_Item__c IN (' + cliIds + ') GROUP BY Contract_Line_Item__c';
			}
			System.debug('*** logging soqlStatement2 ***' + soqlStatement);
		}
	}

	public interface IFLIStartDateAggregation {
		List<FulfillmentStartDateService.AggregateDataObject> loadData();
	}

	public class AggregateDataObject {
		public Id contractLineItemId { get; set; }
		public Date maxEndDate { get; set; }
		public Date maxCreatedDate { get; Set; }

	}
}