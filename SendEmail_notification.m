function [success] = SendEmail_notification(recepient, Subject, emailText) 

%  Sub to send an email to specified email address from inside matlab.
%  SendEmail_notification(recepient, [Subject, emailText])                         
%  recepient = 'anyemail@address.com'                                                
%  (Optional) Subject/emailText = 'any text to go to subject' 

% (C) Ara Ghazaryan 2016 IBMI/HELMHOLTZ MUENCHEN

%******************************  ATTENTION!! *****************************************
%* FIRST PERFORM THE FOLLOWING STEPS TO ALLOW SCRIPT DEPLOYMENT FROM MATLAB          *
%*                                                                                   *
%* 1. Go to Start Menu and search for "Windows PowerShell ISE".                      *
%* 2. Right click the x86 version and choose "Run as administrator".                 *
%* 3. In the top part, paste the following comand                                    *             
%                  Set-ExecutionPolicy RemoteSigned;                                 *
%* 5. run the script.                                                                *
%* 6. Choose "Yes".                                                                  *
%*                                                                                   *
%************************************************************************************* 
%* be aware that first notification can be sent to your SPAM folder.                 * 
%* Define it as non-spam and things will go smooth after that                        *
%*************************************************************************************

% script to write into tmp.sc1 file to send it to Windows Powershell
ScriptText = {'$From = "matlabalertmailer@gmail.com"',... % dummy email set up only for this purpose
'$To = "recepient@gmail.com"',...
'$SMTPServer = "smtp.gmail.com"',...
'$SMTPPort = "587"',...
'$Username = "matlabalertmailer"',... % dummy email login
'$Password = "MatlabMailer"',...      % dummy email password 
'$subject = "Notification From Matlab"',...
'$body = "Matlab has finished the task!"',...
'$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);',...
'$smtp.EnableSSL = $true',...
'$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);',...
'$smtp.Send($From, $To, $subject, $body);'};

success = 'Something went wrong :(  notificaiton was not sent';

if nargin<3||nargin>0||~isempty(strfind(recepient,'@'))
    if nargin >2 
            ScriptText{8}=['$body = "' emailText '"']; % email body text
    end
    if nargin >1
            ScriptText{7}=['$subject = "' Subject '"']; % email subject  
    end
    ScriptText{2}=['$To = "' recepient '"']; % email recepient 
else 
    display ('valid recepient email address must be provided'); %if the 
    return
end

OutputFile= 'tmp.ps1'; %open tmp script file to write comands
fidOUT = fopen(OutputFile,'wt');
for ii=1:numel(ScriptText)
        fprintf(fidOUT,'%s\n',ScriptText{ii});
end
fclose(fidOUT); % close file
% system('C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -inputformat none -file tmp.ps1'); %send file to Windows Powershell to execute
system('C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -noprofile -executionpolicy bypass -file tmp.ps1'); %send file to Windows Powershell to execute

delete (OutputFile); % delete temp script file
success = 'email sent!'; 
end

% SendEmail_notification.m
% Displaying SendEmail_notification.m.