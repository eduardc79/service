global class AccountWeatherScheduleJobClass implements Schedulable {
    global void execute(SchedulableContext SC) {
        AccountWeatherUpdateBatch  bc = new AccountWeatherUpdateBatch ();
        database.executeBatch(bc, 100);
    }
}
//run in Developer Console
// System.schedule('Account Updater: at 1 h', '0 0 1 * * ?', new AccountWeatherScheduleJobClass());
