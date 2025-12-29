/**
 * Author: Sukesh Subash
 * Date: 26/12/2025 
 * Description: This class is used as a Queueable job to send escalation email notifications to Contacts associated with escalated Cases. 
 */
public with sharing class SendEscalationEmailQueueable implements Queueable { // Added 'with sharing' based on requirement 
    
    private static final String CLASS_NAME = 'SendEscalationEmailQueueable - ';
    private Set<Id> contactIds;

    /**
     * Method Name: SendEscalationEmailQueueable (Constructor)
     * Description: Initializes the class and evaluates input parameters. 
     */
    public SendEscalationEmailQueueable(Set<Id> contactIds) {
        // Evaluate the method input parameter for null 
        this.contactIds = (contactIds != null) ? contactIds : new Set<Id>(); 
    }

    /**
     * Method Name : execute 
     * Description : Sends escalation email notifications to Contacts associated with escalated Cases. 
     * @param context : QueueableContext provided by Salesforce runtime. 
     */
    public void execute(QueueableContext context) {
        final String METHOD_NAME = 'execute';
        

        List<Contact> contacts = [
            SELECT Id, Email 
            FROM Contact 
            WHERE Id IN :contactIds 
            AND Email != null
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Contact con : contacts) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ con.Email });
            mail.setSubject('Case Escalated');
            mail.setPlainTextBody(
                'Hello,\n\nYour case has been escalated. Our team will contact you shortly.'
            );
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

        // Debug statement at the end of the method with output/result count 
        System.debug(LoggingLevel.DEBUG, emails.size());
    }
}