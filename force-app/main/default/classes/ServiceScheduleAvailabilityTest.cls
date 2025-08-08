@IsTest
private class ServiceScheduleAvailabilityTest {

    @TestSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(
            FirstName        = 'User Agent',
            LastName         = 'Test',
            Alias            = 'uagtst01',
            Email            = 'user.agent.test+' + System.now().getTime() + '@example.com',
            Username         = 'user.agent.test.' + System.now().getTime() + '@example.com',
            TimeZoneSidKey   = 'GMT',
            LocaleSidKey     = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey= 'en_US',
            ProfileId        = p.Id
        );
        insert u;
    }

    private static User getAgentUser() {
        return [SELECT Id, TimeZoneSidKey FROM User WHERE Name = 'User Agent Test' LIMIT 1];
    }

    private static Datetime tomorrowAt(Integer hour, Integer minute) {
        Date d = Date.today().addDays(1);
        return Datetime.newInstance(d, Time.newInstance(hour, minute, 0, 0));
    }

    private static List<String> allSlots() {
        return new List<String>{'08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00'};
    }

    @IsTest
    static void test_noEvents_allSlotsAvailable() {
        User u = getAgentUser();
        System.runAs(u) {
            List<List<String>> res = ServiceScheduleAvailability.getAvailableSlots();
            System.assertEquals(1, res.size());
            List<String> slots = res[0];
            System.assertEquals(allSlots(), slots);
        }
    }

    @IsTest
    static void test_oneEvent_removesThatHour() {
        User u = getAgentUser();
        System.runAs(u) {
            Event e9 = new Event(
                Subject        = 'Service Request',
                StartDateTime  = tomorrowAt(9,0),
                EndDateTime    = tomorrowAt(10,0),
                OwnerId        = u.Id
            );
            insert e9;

            List<List<String>> res = ServiceScheduleAvailability.getAvailableSlots();
            List<String> slots = res[0];

            System.assert(!slots.contains('09:00'));
            System.assertEquals(9, slots.size());
        }
    }

    @IsTest
    static void test_twoEvents_removeBothHours() {
        User u = getAgentUser();
        System.runAs(u) {
            Event e9 = new Event(
                Subject       = 'Service Request',
                StartDateTime = tomorrowAt(9,0),
                EndDateTime   = tomorrowAt(10,0),
                OwnerId       = u.Id
            );
            Event e13 = new Event(
                Subject       = 'Service Request',
                StartDateTime = tomorrowAt(13,0),
                EndDateTime   = tomorrowAt(14,0),
                OwnerId       = u.Id
            );
            insert new List<Event>{ e9, e13 };

            List<List<String>> res = ServiceScheduleAvailability.getAvailableSlots();
            List<String> slots = res[0];

            System.assert(!slots.contains('09:00'));
            System.assert(!slots.contains('13:00'));
            System.assertEquals(8, slots.size());
        }
    }
}