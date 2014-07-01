/* A wrapper around ntlm_auth to log arguments and 
running time. 
WARNING: We cheat and do no bother to free memory allocated to strings here. 
The process is meant to be very short lived an never reused. */

#define COMMAND "/usr/bin/ntlm_auth"
#include <syslog.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <errno.h>
#include <linux/limits.h>

int safe_system(char* file,char *argv[],char *envp[]);

int main(argc,argv,envp) int argc; char **argv, **envp;
{
    struct timeval t1, t2;
    double elapsed;
    char log_msg[ ARG_MAX ] = COMMAND;
    char *sep = " ";
    int i,arg_length,space_left,ret = 1 ; // return code

    openlog("radius-debug", LOG_PID, LOG_LOCAL4);
    space_left  = ( ARG_MAX - ( strlen(log_msg) + 1) ); 

    // concatenate the command with all argv args separated by sep
    for (i = 1; i < argc; i++) {

        // skip the excluded args
        if (( strncmp(argv[i], "--password", 10 )  == 0 ) ||
            ( strncmp(argv[i], "--challenge", 11 ) == 0 )) 
            continue;

        // build the log message
        space_left  -= strlen(argv[i]) + 1;
        strncat(log_msg, sep, space_left);
        strncat(log_msg, argv[i], space_left );

    }


    argv[0] = COMMAND;
    gettimeofday(&t1, NULL);
    ret = safe_system(COMMAND,argv,envp);

    gettimeofday(&t2, NULL);
    elapsed = (t2.tv_sec - t1.tv_sec) * 1000.0;      // sec to ms
    elapsed += (t2.tv_usec - t1.tv_usec) / 1000.0;   // us to ms

    syslog(LOG_INFO, "%s time: %g ms", log_msg, elapsed);
    closelog();

    exit(WEXITSTATUS(ret));
}


int safe_system(char* file,char *argv[],char *envp[])
{
    sigset_t blockMask, origMask;
    struct sigaction saIgnore, saOrigQuit, saOrigInt, saDefault;
    pid_t childPid;
    int status, savedErrno;

    /* The parent process (the caller of system()) blocks SIGCHLD
       and ignore SIGINT and SIGQUIT while the child is executing.
       We must change the signal settings prior to forking, to avoid
       possible race conditions. This means that we must undo the
       effects of the following in the child after fork(). */

    sigemptyset(&blockMask);            /* Block SIGCHLD */
    sigaddset(&blockMask, SIGCHLD);
    sigprocmask(SIG_BLOCK, &blockMask, &origMask);

    saIgnore.sa_handler = SIG_IGN;      /* Ignore SIGINT and SIGQUIT */
    saIgnore.sa_flags = 0;
    sigemptyset(&saIgnore.sa_mask);
    sigaction(SIGINT, &saIgnore, &saOrigInt);
    sigaction(SIGQUIT, &saIgnore, &saOrigQuit);

    switch (childPid = fork()) {
    case -1: /* fork() failed */
        status = -1;
        break;          /* Carry on to reset signal attributes */

    case 0: /* Child: exec command */

        /* We ignore possible error returns because the only specified error
           is for a failed exec(), and because errors in these calls can't
           affect the caller of system() (which is a separate process) */

        saDefault.sa_handler = SIG_DFL;
        saDefault.sa_flags = 0;
        sigemptyset(&saDefault.sa_mask);

        if (saOrigInt.sa_handler != SIG_IGN)
            sigaction(SIGINT, &saDefault, NULL);
        if (saOrigQuit.sa_handler != SIG_IGN)
            sigaction(SIGQUIT, &saDefault, NULL);

        sigprocmask(SIG_SETMASK, &origMask, NULL);

        execve(file,argv,envp);
        _exit(127);                     /* We could not exec the shell */

    default: /* Parent: wait for our child to terminate */

        /* We must use waitpid() for this task; using wait() could inadvertently
           collect the status of one of the caller's other children */

        while (waitpid(childPid, &status, 0) == -1) {
            if (errno != EINTR) {       /* Error other than EINTR */
                status = -1;
                break;                  /* So exit loop */
            }
        }
        break;
    }

    /* Unblock SIGCHLD, restore dispositions of SIGINT and SIGQUIT */

    savedErrno = errno;                 /* The following may change 'errno' */

    sigprocmask(SIG_SETMASK, &origMask, NULL);
    sigaction(SIGINT, &saOrigInt, NULL);
    sigaction(SIGQUIT, &saOrigQuit, NULL);

    errno = savedErrno;

    return status;
}
