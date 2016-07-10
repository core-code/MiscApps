/*
 * Copyright (c) 2003 Todd C. Miller <Todd.Miller@courtesan.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Sponsored in part by the Defense Advanced Research Projects
 * Agency (DARPA) and Air Force Research Laboratory, Air Force
 * Materiel Command, USAF, under agreement number F39502-99-1-0512.
 */

#if 0
#ifndef lint
static char sccsid[] = "@(#)diff.c	8.1 (Berkeley) 6/6/93";
#endif
#endif /* not lint */
#include <sys/cdefs.h>

#pragma GCC diagnostic ignored "-Wunreachable-code"
#pragma GCC diagnostic ignored "-Wformat-nonliteral"
#pragma GCC diagnostic ignored "-Wmissing-noreturn"

#include <sys/param.h>
#include <sys/stat.h>

#include <ctype.h>
#include <err.h>
#include <errno.h>
#include <getopt.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "diff.h"
#include "pathnames.h"
#include <time.h>
#include <assert.h>
int	aflag, bflag, cflag, dflag, Eflag, iflag, lflag, Nflag, Pflag, pflag, rflag;
int	sflag, tflag, Tflag, wflag, Toflag, Fromflag;
int	Bflag, yflag;
int filebehave;
int strip_cr, suppress_cl, tabsize = 8;
char ignore_file_case = 0;
int	format, context, status;
char *start, *ifdefname, *diffargs, *label[2], *ignore_pats, *line_format, *group_format;
struct stat stb1, stb2;
struct excludes *excludes_list;
regex_t	 ignore_re;

int flag_opts = 0;

#define	OPTIONS	"0123456789aBbC:cdD:EefhI:iL:lnNPpqrS:sTtU:uvwXy:x"


/* Options which exceed manageable alphanumeric assignments */ 
enum 
{
  OPT_IGN_FN_CASE = CHAR_MAX + 1,
  OPT_NIGN_FN_CASE,
  OPT_STRIPCR,
  OPT_NORMAL,
  OPT_LEFTC,
  OPT_SUPCL,
  OPT_CHGD_GF,
  OPT_NEW_GF,
  OPT_OLD_GF,
  OPT_UNCHGD_GF,
  OPT_LF,
  OPT_LLF,
  OPT_TSIZE,
  OPT_FFILE,
  OPT_TOFILE,
  OPT_HLINES,
  OPT_LFILES,
  OPT_HELP,
  OPT_NEW_LF,
  OPT_OLD_LF,
  OPT_UNCHGD_LF,
};


static struct option longopts[] = {
	
	/*
	 * Commented-out options are unimplemented.
	 */

	{ "brief",			no_argument,		NULL,	'q' },
	{ "changed-group-format",		required_argument,	NULL,	OPT_CHGD_GF},
	{ "context",			optional_argument,	NULL,	'C' },
	{ "ed",				no_argument,		NULL,	'e' },
	{ "exclude",			required_argument,	NULL,	'x' },
	{ "exclude-from",		required_argument,	NULL,	'X' },
	{ "expand-tabs",		no_argument,		NULL,	't' },
	{ "from-file",			required_argument,	NULL,	OPT_FFILE },
	{ "forward-ed",			no_argument,		NULL,	'f' },
	{ "help",			no_argument,		NULL,	OPT_HELP },
	/*{ "horizon-lines",		required_argument,	NULL,	OPT_HLINES },*/
	{ "ifdef",			required_argument,	NULL,	'D' },
	{ "ignore-all-space",		no_argument,		NULL,	'W' },
	{ "ignore-blank-lines",		no_argument,		NULL,	'B' },
 	{ "ignore-case",		no_argument,		NULL,	'i' },
	{ "ignore-file-name-case",	no_argument,		NULL,	OPT_IGN_FN_CASE },
	{ "ignore-matching-lines",	required_argument,	NULL,	'I' },
	{ "ignore-space-change",	no_argument,		NULL,	'b' },
	{ "ignore-tab-expansion",	no_argument,		NULL,	'E' },
	{ "initial-tab",		no_argument,		NULL,	'T' },
	{ "label",			required_argument,	NULL,	'L' },
	{ "left-column",		no_argument,		NULL,	OPT_LEFTC },
	{ "line-format",		required_argument,	NULL,	OPT_LF },
	{ "minimal",			no_argument,		NULL,	'd' },
	{ "new-file",			no_argument,		NULL,	'N' },
	{ "new-line-format",		required_argument,		NULL,	OPT_NEW_LF},
	{ "new-group-format",		required_argument,		NULL, 	OPT_NEW_GF},
	{ "no-ignore-file-name-case",	no_argument,		NULL,	OPT_NIGN_FN_CASE },
	{ "normal",			no_argument,		NULL,	OPT_NORMAL },
	{ "old-line-format",		required_argument,		NULL,	OPT_OLD_LF},
	{ "old-group-format",		required_argument,		NULL,	OPT_OLD_GF},
	{ "paginate",			no_argument,		NULL,	'l' },
	{ "recursive",			no_argument,		NULL,	'r' },
	{ "report-identical-files",	no_argument,		NULL,	's' },
	{ "rcs",			no_argument,		NULL,	'n' },
	{ "show-c-function",		no_argument,		NULL,	'p' },
	{ "show-function-line",		required_argument,	NULL,	'F' },
	{ "side-by-side",		no_argument,		NULL,	'y' },
	/*{ "speed-large-files",		no_argument,		NULL,	OPT_LFILES }, */
	{ "starting-file",		required_argument,	NULL,	'S' },	
	{ "strip-trailing-cr",		no_argument,		NULL,	OPT_STRIPCR },
	{ "suppress-common-lines",	no_argument,		NULL,	OPT_SUPCL },
	{ "tabsize",			optional_argument,	NULL,	OPT_TSIZE },
	{ "text",			no_argument,		NULL,	'a' },
	{ "to-file",			required_argument,	NULL,	OPT_TOFILE },
	{ "unchanged-group-format",		required_argument,			NULL,	OPT_UNCHGD_GF},
	{ "unchanged-line-format",		required_argument,			NULL,	OPT_UNCHGD_LF},
	{ "unidirectional-new-file",	no_argument,		NULL,	'P' },
	{ "unified",			optional_argument,	NULL,	'U' },
	{ "version",			no_argument,		NULL,	'v' },
	/*{ "width",			optional_argument,	NULL,	'w' }, */
	{ NULL,				0,			NULL,	'\0'}
};

static const char *help_msg[] = { 
"\t-a --text  treat files as ASCII text",
"\t-B --ignore-blank-lines  Ignore blank newlines in the comparison",
"\t-b --ignore-space-change  Ignore all changes due to whitespace",
"\t-C -c NUM --context=NUM  Show NUM lines before and after change (default 3)",
"\t-D --ifdef=NAME  Output merged file with `#ifdef NAME' diffs",
"\t-E --ignore-tab-expansion  Ignore tab expansion in the comparison",
"\t-e --ed  Output an ed script",
"\t-F --show-function-line=RE	 Show the most recent line matching RE",
"\t-f --forward-ed  Output a forward ed script",
"\t-I --ignore-matching-lines=RE  Ignore changes whose lines all match RE",
"\t-i --ignore-case  Ignore case differences in file contents",
"\t-L --label=NAME  Label file header",
"\t-l --paginate  Paginates output through pr",
"\t-N --new-file  Treat new files as empty",
"\t-n --rcs  Output an RCS format diff",
"\t-P --unidirectional-new-file  Treat absent-first files as empty",
"\t-p --show-c-function  Show which C function each change is in",
"\t-q --brief  report only when files differ",
"\t-r --recursive Recursively compare any sub-directories found",
"\t-S --starting-file=FILE  Start with FILE when comparing directories",
"\t-s --report-identical-files Report when two files are the same",
"\t-T --initial-tab  Make tabs line up by prepending a tab",
"\t-t --expand-tabs  Expand tabs to spaces in output",
"\t-U -u NUM --unified=NUM  Show NUM lines of unified context",
"\t-v --version  Show diff version",
"\t-W --ignore-all-space Ignore all space",
"\t-w --width=NUM Output at most NUM (default 130) print columns",
"\t-X --exclude-from=FILE  Start with FILE when comparing directories",
"\t-x --exclude=PAT  Exclude files that match PAT",
"\t-y --side-by-side  Output difference in two columns",
"\t--GTYPE-group-format=GFMT  Format GTYPE input groups with GFMT",
"\t--LTYPE-line-format=LFMT  Format LTYPE input lines with LFMT",
"\t--from-file=FILE  Compare FILE to all operands",
"\t--to-file=FILE  Compare all operands to FILE",
"\t--ignore-file-name-case  Ignore file name case",
"\t--left-column  Output the only the left column of common lines",
"\t--line-format=LFMT Format all input lines with LFMT",
"\t--no-ignore-file-name-case Do not ignore file name case",
"\t--normal  Output a normal diff (default output)",
"\t--strip-trailing-cr  Strip trailing carriage return",
"\t--suppress-common-lines  Do not output common lines",
"\t--tabsize=NUM  Tab stops every NUM (default 8) print columns",
"\t--help  Output this help message",
NULL,
};
char **help_strs = (char **)help_msg;

extern FILE *buffer;

static void set_argstr(char **, char **);
static void usage(void);
static void push_excludes(char *);
static void push_ignore_pats(char *);
static void read_excludes_file(char *);
FILE *buffer;
void
pseudomain(int argc, char **argv, FILE *file)
{
	buffer = file;
	char *ep, **oargv, *optfile;
	const char *pn;
	long l;
	int ch, lastch, gotstdin, prevoptind, newarg;
//	int oargc;
	
	filebehave = FILE_NORMAL;
	/* Check what is the program name of the binary.  In this
	   way we can have all the funcionalities in one binary
	   without the need of scripting and using ugly hacks. */
	pn = getprogname();
	if (pn[0] == 'z') {
		filebehave = FILE_GZIP;
	}
	
	oargv = argv;
//	oargc = argc;
	gotstdin = 0;
	optfile = "\0";

	lastch = '\0';
	prevoptind = 1;
	newarg = 1;
	while ((ch = getopt_long(argc, argv, OPTIONS, longopts, NULL)) != -1) {
		switch (ch) {
		case '0': case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			if (newarg)
				usage();	/* disallow -[0-9]+ */
			else if (lastch == 'c' || lastch == 'u')
				context = 0;
			else if (!isdigit(lastch) || context > INT_MAX / 10)
				usage();
			context = (context * 10) + (ch - '0');
			break;
		case 'a':
			aflag = 1;
			break;
		case 'b':
			bflag = 1;
			break;
		case 'B':
			Bflag = 1;
			break;
		case 'C':
		case 'c':
			cflag = 1;
			format = D_CONTEXT;
			if (optarg != NULL) {
				l = strtol(optarg, &ep, 10);
				if (*ep != '\0' || l < 0 || l >= INT_MAX)
					usage();
				context = (int)l;
			} else
				context = 3;
			break;
		case 'D':
			format = D_IFDEF;
			ifdefname = optarg;
			break;
		case 'd':
			dflag = 1;
			break;
		case 'E':
			Eflag = 1;
			break;
		case 'e':
			format = D_EDIT;
			break;
		case 'f':
			format = D_REVERSE;
			break;
		case 'h':
			/* silently ignore for backwards compatibility */
			break;
		case 'I':
			push_ignore_pats(optarg);
			break;
		case 'i':
			iflag = 1;
			break;
		case 'L':
			if (label[0] == NULL)
				label[0] = optarg;
			else if (label[1] == NULL)
				label[1] = optarg;
			else
				usage();
			break;
		case 'l':
			lflag = 1;
			signal(SIGPIPE, SIG_IGN);
			break;
		case 'N':
			Nflag = 1;
			break;
		case 'n':
			format = D_NREVERSE;
			break;
		case 'P':
			Pflag = 1;
			break;
		case 'p':
			pflag = 1;
			break;
		case 'r':
			rflag = 1;
			break;
		case 'q':
			format = D_BRIEF;
			break;
		case 'S':
			start = optarg;
			break;
		case 's':
			sflag = 1;
			break;
		case 'T':
			Tflag = 1;
			break;
		case 't':
			tflag = 1;
			break;
		case 'U':
		case 'u':
			format = D_UNIFIED;
			if (optarg != NULL) {
				l = strtol(optarg, &ep, 10);
				if (*ep != '\0' || l < 0 || l >= INT_MAX)
					usage();
				context = (int)l;
			} else
				context = 3;
			break;
		case 'v':
			fprintf(buffer, "FreeBSD diff 2.8.7\n");
			exit(0);
		case 'W':
			wflag = 1;
			break;
		case 'X':
			read_excludes_file(optarg);
			break;
		case 'x':
			push_excludes(optarg);
			break;
		case 'y':
			yflag = 1;
			break;
		case OPT_FFILE:
			Toflag = 1;
			optfile = optarg;
			break;
		case OPT_TOFILE:
			Fromflag = 1;
			optfile = optarg;
			break;
		case OPT_CHGD_GF:
		case OPT_NEW_GF:
		case OPT_OLD_GF:
		case OPT_UNCHGD_GF:
			/* XXX To do: Complete --GTYPE-group-format. */
			format = D_GF;
			group_format = optarg;
			break;
		case OPT_NEW_LF:
		case OPT_OLD_LF:
		case OPT_UNCHGD_LF:
		case OPT_LF:
			/* XXX To do: Complete --line-format. */
			format = D_LF;
			line_format = optarg;
			break;
		case OPT_NORMAL:
			format = D_NORMAL;
			break;
		case OPT_LEFTC:
			/* Do nothing, passes option to sdiff. */
			break;
		case OPT_SUPCL:
			/* Do nothing, passes option to sdiff. */
			break;
		case OPT_TSIZE:
			if (optarg != NULL) {
				l = strtol(optarg, &ep, 10);
				if (*ep != '\0' || l < 1 || l >= INT_MAX)
					usage();
				tabsize = (int)l;
			} else 
			tabsize = 8;
			break; 
		case OPT_STRIPCR:
			strip_cr=1;
			break;
		case OPT_IGN_FN_CASE:
			ignore_file_case = 1;
			break;
		case OPT_NIGN_FN_CASE:
			ignore_file_case = 0;
			break; 
		case OPT_HELP:
			for (; *help_strs; help_strs++) {
				fprintf(buffer, "%s\n", *help_strs);
			}
			exit(0);
			break;
		default:
			usage();
			break;
		}
		lastch = ch;
		newarg = optind != prevoptind;
		prevoptind = optind;
		
	}
	argc -= optind;
	argv += optind;
//	if (yflag) {
//		/* remove y flag from args and call sdiff */
//		for (argv = oargv; argv && strcmp(*argv, "-y") != 0 && 
//			strcmp(*argv, "--side-by-side") != 0; argv++);
//		while(argv != &oargv[oargc]){
//			*argv= *(argv+1);
//			argv++;
//		}
//		oargv[0] = _PATH_SDIFF;
//		*argv= "\0";
//		execv(_PATH_SDIFF, oargv);
//		_exit(1);
//	}

	/*
	 * Do sanity checks, fill in stb1 and stb2 and call the appropriate
	 * driver routine.  Both drivers use the contents of stb1 and stb2.
	 */
	if (argc != 2)
		usage();
	if (ignore_pats != NULL) {
		char buf[BUFSIZ];
		int error;

		if ((error = regcomp(&ignore_re, ignore_pats,
		    REG_NEWLINE | REG_EXTENDED)) != 0) {
			regerror(error, &ignore_re, buf, sizeof(buf));
			if (*ignore_pats != '\0')
				errx(2, "%s: %s", ignore_pats, buf);
			else
				errx(2, "%s", buf);
		}
	}
	if (strcmp(argv[0], "-") == 0) {
		fstat(STDIN_FILENO, &stb1);
		gotstdin = 1;
	} else if (stat(argv[0], &stb1) != 0)
		err(2, "%s", argv[0]);
	if (strcmp(argv[1], "-") == 0) {
		fstat(STDIN_FILENO, &stb2);
		gotstdin = 1;
	} else if (stat(argv[1], &stb2) != 0)
		err(2, "%s", argv[1]);
	if (gotstdin && (S_ISDIR(stb1.st_mode) || S_ISDIR(stb2.st_mode)))
		errx(2, "can't compare - to a directory");
	set_argstr(oargv, argv);
	if (S_ISDIR(stb1.st_mode) && S_ISDIR(stb2.st_mode)) {
		if (format == D_IFDEF)
			if (ch == 'D') 
				errx(2, "-D option not supported with directories");
			if (ch == OPT_LF) 
				errx(2, "--line-format option not supported with directories");
		diffdir(argv[0], argv[1]);
	} else
	{
		if (S_ISDIR(stb1.st_mode)) {
			argv[0] = splice(argv[0], argv[1]);
			if (stat(argv[0], &stb1) < 0)
				err(2, "%s", argv[0]);
		}
		if (S_ISDIR(stb2.st_mode)) {
			argv[1] = splice(argv[1], argv[0]);
			if (stat(argv[1], &stb2) < 0)
				err(2, "%s", argv[1]);
		}
		/* Checks if --to-file or --from-file are specified */
		if (Toflag && Fromflag) {
			(void)fprintf(stderr, "--from-file and --to-file both specified.\n");
			exit(1);				
		}
		if (Toflag) {
			print_status(diffreg(optfile, argv[0], 0), optfile, argv[0],
			NULL);
			print_status(diffreg(optfile, argv[1], 0), optfile, argv[1],
			NULL);
		}
		if (Fromflag) {
			print_status(diffreg(argv[0], optfile, 0), argv[0], optfile,
			NULL);
			print_status(diffreg(argv[1], optfile, 0), argv[1], optfile,
			NULL);			
		}
		if (!Toflag && !Fromflag)
			print_status(diffreg(argv[0], argv[1], 0), argv[0], argv[1],
				NULL);
	}
}

void *
emalloc(size_t n)
{
	void *p;

	if (n == 0)
		errx(2, NULL);
	if ((p = malloc(n)) == NULL)
		errx(2, NULL);
	return (p);
}

void *
erealloc(void *p, size_t n)
{
	void *q;

	if (n == 0)
		errx(2, NULL);
	if (p == NULL)
		q = malloc(n);
	else
		q = realloc(p, n);
	if (q == NULL)
		errx(2, NULL);
	return (q);
}

int
easprintf(char **ret, const char *fmt, ...)
{
	int len;
	va_list ap;

	va_start(ap, fmt);
	len = vasprintf(ret, fmt, ap);
	va_end(ap);
	if (len < 0 || *ret == NULL)
		errx(2, NULL);
	return (len);
}

char *
estrdup(const char *str)
{
	size_t len;
	char *cp;
	assert(str);
	len = strlen(str) + 1;
	cp = emalloc(len);
	
	strlcpy(cp, str, len);
	return (cp);
}

static void
set_argstr(char **av, char **ave)
{
	size_t argsize;
	char **ap;

	argsize = 4 + *ave - *av + 1;
	diffargs = emalloc(argsize);
	strlcpy(diffargs, "diff", argsize);
	for (ap = av + 1; ap < ave; ap++) {
		if (strcmp(*ap, "--") != 0) {
			strlcat(diffargs, " ", argsize);
			strlcat(diffargs, *ap, argsize);
		}
	}
}

/*
 * Read in an excludes file and push each line.
 */
static void
read_excludes_file(char *file)
{
	FILE *fp;
	char *buf, *pattern;
	size_t len;

	if (strcmp(file, "-") == 0)
		fp = stdin;
	else if ((fp = fopen(file, "r")) == NULL)
		err(2, "%s", file);
	while ((buf = fgetln(fp, &len)) != NULL) {
		if (buf[len - 1] == '\n')
			len--;
		pattern = emalloc(len + 1);
		memcpy(pattern, buf, len);
		pattern[len] = '\0';
		push_excludes(pattern);
	}
	if (strcmp(file, "-") != 0)
		fclose(fp);
}

/*
 * Push a pattern onto the excludes list.
 */
static void
push_excludes(char *pattern)
{
	struct excludes	*entry;

	entry = emalloc(sizeof(*entry));
	entry->pattern = pattern;
	entry->next = excludes_list;
	excludes_list = entry;
}

static void
push_ignore_pats(char *pattern)
{
	size_t len;
	assert(pattern);
	if (ignore_pats == NULL)
		ignore_pats = estrdup(pattern);
	else {
		/* old + "|" + new + NUL */
		len = strlen(ignore_pats) + strlen(pattern) + 2;
		ignore_pats = erealloc(ignore_pats, len);
		strlcat(ignore_pats, "|", len);
		strlcat(ignore_pats, pattern, len);
	}
}

void
print_only(const char *path, size_t dirlen, const char *entry)
{
	
	if (dirlen > 1)
		dirlen--;
	fprintf(buffer, "Only in %.*s: %s\n", (int)dirlen, path, entry);
}

void
print_status(int val, char *path1, char *path2, char *entry)
{
	
	switch (val) {
	case D_ONLY:
		print_only(path1, strlen(path1), entry);
		break;
	case D_COMMON:
		fprintf(buffer, "Common subdirectories: %s%s and %s%s\n",
			path1, entry ? entry : "", path2, entry ? entry : "");
		break;
	case D_BINARY:
		fprintf(buffer, "Files %s%s and %s%s differ\n",
			path1, entry ? entry : "", path2, entry ? entry : "");
		break;
	case D_DIFFER:
		if (format == D_BRIEF)
			fprintf(buffer, "Files %s%s and %s%s differ\n",
				path1, entry ? entry : "",
				path2, entry ? entry : "");
		break;
	case D_SAME:
		if (sflag)
			fprintf(buffer, "Files %s%s and %s%s are identical\n",
				path1, entry ? entry : "",
				path2, entry ? entry : "");
		break;
	case D_MISMATCH1:
		fprintf(buffer, "File %s%s is a directory while file %s%s is a regular file\n",
			path1, entry ? entry : "", path2, entry ? entry : "");
		break;
	case D_MISMATCH2:
		fprintf(buffer, "File %s%s is a regular file while file %s%s is a directory\n",
			path1, entry ? entry : "", path2, entry ? entry : "");
		break;
	case D_SKIPPED1:
		fprintf(buffer, "File %s%s is not a regular file or directory and was skipped\n",
			path1, entry ? entry : "");
		break;
	case D_SKIPPED2:
		fprintf(buffer, "File %s%s is not a regular file or directory and was skipped\n",
			path2, entry ? entry : "");
		break;
	}
}

static void
usage(void)
{
	
	(void)fprintf(stderr,
	    "usage: %s [-abdilpqTtw] [-I pattern] [-c | -e | -f | -n | -u]\n"
	    "            [-L label] file1 file2\n"
	    "          [-abdilpqTtw] [-I pattern] [-L label] -C number file1 file2\n"
	    "          [-abdilqtw] [-I pattern] -D string file1 file2\n"
	    "          [-abdilpqTtw] [-I pattern] [-L label] -U number file1 file2\n"
	    "          [-abdilNPpqrsTtw] [-I pattern] [-c | -e | -f | -n | -u]\n"
	    "            [-L label] [-S name] [-X file] [-x pattern] dir1 dir2\n"
	    "          [-v]\n", getprogname());

	exit(1);
}
