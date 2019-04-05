import os
import smtplib
import mimetypes
import optparse
from email.message import EmailMessage

aws_ses_user = os.environ['AWS_EMAIL_USER']
aws_ses_pwd = os.environ['AWS_EMAIL_PWD']

def path_leaf(path):
    head, tail = os.path.split(path)
    return tail or os.path.basename(head)

psr = optparse.OptionParser(usage="Usage: %prog [--exp=name] attachments")
psr.add_option("-e", "--exp", action="store", type="string", dest="exp", default="",
               help="Specify name of the experiment.")

opts, args = psr.parse_args()
title = "untitled"
if (opts.exp != ""):
    title = opts.exp

content = 'Experiment: {} is done.'.format(title)

msg = EmailMessage()

for filename in args:
    path = os.path.join('./', filename)
    if not os.path.isfile(path):
        content += '\n\rInfo: File \"{}\" not found, not attached.'.format(filename)
msg.set_content(content)

msg['Subject'] = 'Experiment Finished'
msg['From'] = 'AWS <hanx@g.harvard.edu>'
msg['To'] = 'hanx@g.harvard.edu'

for filename in args:
    path = os.path.join('./', filename)
    if os.path.isfile(path):
        ctype, encoding = mimetypes.guess_type(path)
        if ctype is None or encoding is not None:
            ctype = 'application/octet-stream'
        maintype, subtype = ctype.split('/', 1)
        with open(path, 'rb') as fp:
            msg.add_attachment(fp.read(),
                               maintype=maintype,
                               subtype=subtype,
                               filename=path_leaf(path))

s = smtplib.SMTP_SSL(host='email-smtp.us-east-1.amazonaws.com')
s.login(aws_ses_user, aws_ses_pwd)
s.send_message(msg)
s.quit()
