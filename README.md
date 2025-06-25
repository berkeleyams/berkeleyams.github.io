Applied Math Seminar Announcement
=================================

Make necessary modifications each semester. For instance, replace fall22,
host names etc by the updated information of the semester. 

The actual website is https://berkeleyams.github.io/, which will be automatically
redirected to https://berkeleyams.lbl.gov/fall22/

0. Update the Google sheet to indicate the speakers you would like to
   invite to help coordination

https://docs.google.com/spreadsheets/d/1S4fqiUZqd_FivdEvU2cXWb6MKWWSJhntjaXJrABD-t0/edit?usp=sharing

1. Github 
make
git add ../fall22/*
git commit -a -m "edit"
git push

2. Annoucement systems (3 places: math department web; LBL system; email
list)

* For campus system (CalNet login required) 

https://nweb.math.berkeley.edu/events/new/ 

* For LBL system:
https://cs.lbl.gov/for-staff/schedule-a-seminar/
and enter info as follows:

- Host Names and Affiliations:
Di Fang, Michael Lindsey, Franziska Weber,  Mathematics Group

- Additional information you want to include in the announcement:
Welcome to the Applied Mathematics seminar for the Fall 2022 semester. This year, the seminar series is being organized by Di Fang (difang@berkeley.edu), Michael Lindsey (lindsey@math.berkeley.edu), and Franziska Weber (fweber@berkeley.edu). If you have any inquiries, please contact one of them.

To join the applied math seminar mailing list, click
https://groups.google.com/a/lists.berkeley.edu/forum/#!forum/appliedmathseminar/join

3. Email announcement to emailing list every Monday (morning preferred; written via the "LBNL-UCB Applied Math Seminar" Google group conversations)



Applied Math Seminar Website Generator by Chris H. Rycroft
==========================================================
This directory contains all of the files necessary for generating the applied
math website. The contents are as follows:

compile.pl - A perl script that will generate an index page and abstract pages
             for all talks in one semester
Makefile - A file for keeping track of dependencies, for knowing which parts of
           the site need to be rebuilt
README - this documentation file
template.html - An HTML file that is used as a template for all of the pages on
                the website 
*.sdb - Database files containing talk/abstract information for all seminars
        in one semester

Maintaining the site is two step process:

1. Make modifications to the .sdb files (described in detail below)
2. Type "make". This will recompile the web pages for any semesters whose
   database files have been modified.


Changing the .sdb files
=======================
The .sdb files have a standard header of four lines, that will look like this:

Semester: Spring 2009
Usual location: 939 Evans Hall
Usual time: 11AM--12PM
Usual day: Friday

This gives the title of the semester and also information about the regular
time and place. The script assumes all talks are held at this time and place
unless it is told otherwise. These four lines must be present in this order;
otherwise, the script gives an error.

After this, there are several blank lines, and then entries about each talk
are given. A typical talk entry is as follows:

Date: September 30th
Speaker: Xuemin Tu
Affiliation: UC Berkeley
Title: Implicit sampling for nonlinear filters
<abstract>
...
</abtract>

The entry must begin with the "Date" field, which tells the script that this is
a new talk, but after that, the entries can appear in any order, or can be left
blank, or omitted. The talk abstract needs to be given between the <abstract>
and </abstract> tags, which need to appear on separate lines. With these tags,
the abstract is assumed to be just plain text. In that case, the script does
some reformatting, adding in <p></p> tags for paragraphs. It assumes a blank
line in the abstract corresponds to a new paragraph.

Some speakers submit more complex abstracts that need to be handled with HTML
directly. In that case, it can be specified with the <html_abstract> and
</html_abstract> tags, and the script just takes everything between these tags
as verbatim HTML.

Another standard type of entry in the database file looks like this:

Date: November 25th
No talk: Thanksgiving

This can be used to generate a placeholder in the index file, for a week when there
is a reason for a break. If the "No talk" entry is specified, it overrides any other
entries that are provided.

Several additional entries are supported:

Time - this gives an alternative time for the seminar on the abstract page,
       overriding the usual one specified in the header
Location - this gives an alternative location on the abstract page, overriding
           the usual one specified in the header
Note - this creates a small note in red italics underneath the date on the
       index page. It is useful for pointing out a non-standard date or time
       for a talk. 


Adding a new .sdb file
======================
Once a new database file is created, the Makefile must be modified so that the
script knows to compile the pages for a new script. A typical line of the
Makefile looks like this:

../fall08/index.html: template.html compile.pl fall08.sdb
	perl compile.pl fall08.sdb

This updates the index page whenever the HTML template, compile script, or
database file are modified.

In addition, the "-c" flag should be passed to the compile script for the most
recent page. The compile script operates slightly differently in this case,
making the seminar index the main page on the site, and also providing links to
previous semesters.


Advanced features
=================
The script contains a number of extra features

- The script automatically analyzes the text abstracts, and does a small amount
  of HTML reformatting. It replaces the `` and '' LaTeX-style quotes with the
  correct 66 and 99 quotation marks. It recognizes "--" as an en-dash and "---"
  as an em-dash. Any occurences of "i.e." or "e.g." are italicized.

- Characters in text abstracts that have other uses in HTML (e.g. ">", "<", and
  "&") are replaced with their HTML codes.

- The script chooses filenames for the abstracts as the lower-case version of
  the speaker's surname. It recognizes some cases where the speaker's name contains
  accented characters that could not be used in a filename.

- The script detects if multiple people with the same surname spoke in the same
  semester.  If so, it calls the HTML files "rycroft.html", "rycroft2.html",
  "rycroft3.html", etc.

- For seminars held in Evans Hall, a link to a map of the campus is provided.
