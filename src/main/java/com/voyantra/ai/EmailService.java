package com.voyantra.ai;

import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import com.voyantra.util.AppConfig;

public class EmailService {

    private static final String SENDER_EMAIL =
        AppConfig.get("EMAIL_SENDER_ADDRESS", "YOUR_GMAIL_ADDRESS_HERE");
    private static final String SENDER_APP_PASSWORD =
        AppConfig.get("EMAIL_SENDER_APP_PASSWORD", "YOUR_GMAIL_APP_PASSWORD_HERE");

    public static void sendOtpEmail(String toEmail, String otp) throws MessagingException {

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.connectiontimeout", "8000");
        props.put("mail.smtp.timeout", "8000");
        props.put("mail.smtp.writetimeout", "8000");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Your Voyantra verification code");
        message.setText("Your OTP code is: " + otp + "\n\nThis code expires in 10 minutes.\n\n- Voyantra AI Travel Planner");

        Transport.send(message);
    }
}