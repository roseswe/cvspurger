# ReadMe CVS-Purger

## RCS, CVS & git
The Concurrent Versions System (CVS) is a free and open-source version control system that was widely used in software development, particularly in the open-source community, before the rise of distributed version control systems like Git. CVS was built upon the Revision Control System (RCS). While RCS managed individual files, CVS extended this capability to manage entire projects (collections of files and directories) and introduced a client-server architecture.

## Motivation and Use Case
I started my programming journey long ago using **RCS** for source code management. As **CVS** emerged, I transitioned to it for its enhanced features. Today, I leverage both **Git** and **CVS**, relying on CVS particularly for its **administrative simplicity** and powerful **keyword substitution** capabilities.

## About CVS Purger

CVS Purger is a bash script utility designed to reduce CVS repository size by purging remote CVS `,v` files that contain too many revisions. By removing older or excessive revisions, it helps maintain the size, performance and manageability of your CVS repository.

>✏️ The first two and the last two commit will be preserved in case a CVS file is purged!

>⚙️  On the remote CVS repository the owner of the CVS files must be in the group `_cvsadmin`!

    cvsremote:$ id
    uid=1000(ralph) gid=1000(ralph) groups=1000(ralph),113(_cvsadmin)

## Features

- **Selective Processing:** Process all files (in the current directory) or a specific file.
- **Clear Console Output:** Provides detailed feedback using UTF-8 characters on the purging process.
- **Lightweight & Efficient:** Quickly reduces CVS repository size without manual intervention.


## Help/Commandline Options
````bash
$ cvspurger.sh -h
Usage: cvspurger.sh [OPTIONS]

Options:
  -?, -h, --help, --usage   Show this help message and exit
  -V, --version             Show version information and exit
  -f, --file <singlefile>   Process only the specified file (instead of all files)
  -r, --revs <number>       Purge if revision count is greater than <number> (default: 30)

````

## Typical output
````bash
$ cvspurger.sh
CVS Purger - purges CVS ,v files with too many revision to reduce the size...
🆗 v.bat, 2 revisions
✅ ver.txt, 143 revisions, purged 1.3:1.141
🆗 Windows-Versionen.md, 2 revisions
[Info]  All done!  Bye...

$ cvspurger.sh -f register.doc
CVS Purger - purges CVS ,v files with too many revisions to reduce the size...
🆗 register.doc, 4 revisions
[Info]  All done!  Bye...

````
## Revision Option

````bash
 $ cvspurger.sh -r 21
CVS Purger Script - purges CVS ,v files with too many revisions to reduce the size...
🆗 BootImagesAll.sh, 4 revisions
🆗 c.rar, 21 revisions
🆗 DosBoot.sh, 7 revisions
🆗 FavBoot.sh, 1 revisions
🆗 GO.BAT, 2 revisions
🆗 m, 8 revisions
🆗 Notes.txt, 1 revisions
🆗 SingleHardDisk-QEMU.sh, 15 revisions
[Info]  All done!  Bye...

$ cvspurger.sh -r 20
CVS Purger Script - purges CVS ,v files with too many revisions to reduce the size...
🆗 BootImagesAll.sh, 4 revisions
✅ c.rar, 21 revisions, purged 1.3:1.19     <----!!!
🆗 DosBoot.sh, 7 revisions
🆗 FavBoot.sh, 1 revisions
🆗 GO.BAT, 2 revisions
🆗 m, 8 revisions
🆗 Notes.txt, 1 revisions
🆗 SingleHardDisk-QEMU.sh, 15 revisions
[Info]  All done!  Bye...
````
If you recheck the file, you see it's truncated to four revisions:
````
$ cvspurger.sh -f c.rar
CVS Purger Script - purges CVS ,v files with too many revisions to reduce the size...
🆗 c.rar, 4 revisions
[Info]  All done!  Bye...
````

## End
<!-- @(#) $Id: cvspurger.md,v 1.2 2025/07/11 12:55:28 ralph Exp $ -->
