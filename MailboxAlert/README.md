
# MailboxAlert
*v1.1.3*

## Description:
MailboxAlert is an application that regularly checks whether your email accounts are filled up to their storage limit, which prevents you from receiving mails. MailboxAlert periodically polls your mailboxes and if one of your accounts is filled above its threshold it lets you know with alerts, on-screen notifications and a changed menubar icon. You can enter as many accounts as you want and freely define polling intervals and thresholds. MailboxAlert supports all standards-compliant IMAP email accounts with and without SSL encryption.

## Requirements:
• Mac OS X 10.8 or later

## License &amp; Cost:
MailboxAlert is completely free of charge and the source code is licensed under the [Open Source "MIT License"][1].

## Contact &amp; Support:
The product website is located here: [https://www.corecode.io/mailboxalert/][2]
Technical support is not available for MailboxAlert.

## Usage:
0.) Download MailboxAlert from the "Mac App Store" and once it has finished downloading start it from Launchpad or your Applications folder.
1.)  The preferences window will be opened automatically the first time you launch MailboxAlert
2.) Make sure to activate the setting to automatically launch MailboxAlert with your computer ("Launch at Login") to be sure that MailboxAlert is always running to protect your email accounts
3.) Make sure to change the settings ("Display App-Icon") to display MailboxAlert in the menubar instead of the Dock, to save precious Dock space and be as unobtrusive as possible.
4.) Configure the email accounts you'd like to see protected by MailboxAlert. To add an account click the plus icon (+) at the lower left corner of the account list. You can import accounts (except the passwords) from Apple's Mail app.  To find out your password you can look it up using the Keychain application. If MailboxAlert can't automatically figure out the storage limit for your account (option "Use server quota" grey and not selectable), you'll need to find out this value, e.g. by asking your email account provider.
5.) Continue operating your Mac normally while MailboxAlert silently checks your email accounts at the specified intervals and will let you know when an account is filled up above its threshold.

[1]: https://opensource.org/licenses/mit-license.php
[2]: https://www.corecode.io/mailboxalert/
