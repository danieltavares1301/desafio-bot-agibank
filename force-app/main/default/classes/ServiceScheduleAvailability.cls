public with sharing class ServiceScheduleAvailability {

    // Retorna horários disponíveis para um usuário específico no dia seguinte
    @InvocableMethod(label='Get Available Slots')
    public static List<List<String>> getAvailableSlots() {

        List<String> possibleSlots = new List<String>{
            '08:00', '09:00', '10:00', '11:00', '12:00',
            '13:00', '14:00', '15:00', '16:00', '17:00'
        };
        
        User agentUser = [SELECT Id FROM User WHERE name='User Agent Test' LIMIT 1]; // não é a melhor forma, mas fiz assim para ser mais "rápido" 
            

        List<Event> userEvents = [
            SELECT StartDateTime, EndDateTime
            FROM Event
            WHERE OwnerId = :agentUser.Id //colocar outro user aqui
              AND DAY_ONLY(StartDateTime) = :Date.today().addDays(1)
        ];

        Set<String> occupiedSlots = new Set<String>();
        for (Event e : userEvents) {
            String eventHour = e.StartDateTime.format('HH:mm');
            occupiedSlots.add(eventHour);
        }

        List<String> availableSlots = new List<String>();
        for (String slot : possibleSlots) {
            if (!occupiedSlots.contains(slot)) {
                availableSlots.add(slot);
            }
        }

        return new List<List<String>>{availableSlots};
    }
}