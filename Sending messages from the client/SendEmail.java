import org.apache.commons.mail.SimpleEmail; 
import org.apache.commons.mail.Email; 

public class SendEmail {  
    public static void main(String[] args) {  
        final String username = "your_username";  
        final String password = "your_password";
    // Создаем сообщение электронной почты  
    SimpleEmail email = new SimpleEmail();  
    email.setHostName("smtp.gmail.com");  
    email.addRecipient(toAddress);  
    email.setSmtpPort(465);  
    email.setAuthenticator(new DefaultAuthenticator(username, password));  
    email.setSSLOnConnect(true);  

        
    try {  
    
        email.send();  
        System.out.println("Сообщение отправлено!");  
    } catch (Exception ex) {  
        ex.printStackTrace();  
    }  
}  
