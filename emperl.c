#include <stdio.h>
#include <EXTERN.h>
#include <perl.h>

#include <xsinit.c>

static PerlInterpreter *my_perl;
static char script[1 << 20];

extern char _binary__________fmtutil_pl_start[];
extern char _binary__________fmtutil_pl_end[];
extern int _binary__________fmtutil_pl_size;

int main(int argc, char **argv, char **env)
{
    //FILE* f = fopen(argv[1], "r");
    //fread(script, sizeof(script), 1, f);
    //fclose(f);
    
    int iSize =  (int)(&_binary__________fmtutil_pl_end - &_binary__________fmtutil_pl_start);

    printf("Size: %d, iSize: %d\n", _binary__________fmtutil_pl_size, iSize);

    char *one_args[] = { "one_perl", "-e", "print($#ARGV); print(123); print(@ARGV); print(456); print($ARGV[0]); print(789); print($ARGV[1]); print(000);", "a", "b", NULL };

    PERL_SYS_INIT3(&argc,&argv,&env);
    my_perl = perl_alloc();
    perl_construct(my_perl);
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
    //perl_parse(my_perl, xs_init, argc, argv, (char **)NULL);
    perl_parse(my_perl, xs_init, 5, one_args, (char **)NULL);
    
    perl_run(my_perl);
    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();
    exit(EXIT_SUCCESS);
}
