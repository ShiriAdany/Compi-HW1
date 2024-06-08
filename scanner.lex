%{
    /* Declarations section */
    #include <stdio.h>
    #include <stddef.h>
    #include <stdint.h>
    #include <string.h>
    #include "tokens.hpp"
    void showToken(char *);
    void append_char(char *dest, char c);

%}

%option yylineno
%option noyywrap

%%
int                 showToken("INT");
byte                showToken("BYTE");
b                   showToken("B");
bool                showToken("BOOL");
and                 showToken("AND");
or                  showToken("OR");
not                 showToken("NOT");
true                showToken("TRUE");
false               showToken("FALSE");
return              showToken("RETURN");
if                  showToken("IF");
else                showToken("ELSE");
while               showToken("WHILE");
break               showToken("BREAK");
continue            showToken("CONTINUE");
[\n\r\t ]
;                   showToken("SC");
\(                  showToken("LPAREN");
\)                  showToken("RPAREN");
\{                  showToken("LBRACE");
\}                  showToken("RBRACE");
=                   showToken("ASSIGN");
==|!=|<=|>=         showToken("RELOP");
\<|\>                 showToken("RELOP");
[+|\-|*|/]           showToken("BINOP");
\/\/[^\n\r]*        showToken("COMMENT");
[A-Za-z][A-Za-z0-9]* showToken("ID");
[1-9][0-9]*|0       showToken("NUM");
\".*?\"                showToken("STRING");
\"                  showToken("UNCLOSED");
.                   showToken("UNKNOWN");

%%

void append_char(char *dest, char c) {
    char temp[2]; // Temporary string to hold the character and null terminator
    temp[0] = c;  // First element is the character
    temp[1] = '\0'; // Second element is the null terminator
    strcat(dest, temp); // Concatenate temp to dest
}

void showToken(char * name) {
    if(name=="COMMENT"){
        printf("%d ", yylineno);
        printf("%s ", name);
        printf("//\n");
    }
    else if(name=="UNKNOWN"){
        printf("Error %s\n", yytext);
        exit(0);
    }
    else if(name == "UNCLOSED"){
        printf("Error unclosed string\n");
        exit(0);
    }
    else if(name=="STRING_ERROR")
    {
        printf("Error unclosed string\n");
        exit(0);
    }
    else if(name=="STRING"){
        char to_print[1024];
        int index =0;
        bool prev_is_backslash = false;
        int length = strlen(yytext);

        for (int i=1; i < length - 1; i++) {
            if (prev_is_backslash) {
                prev_is_backslash = false;
                if (yytext[i] == 92 || yytext[i] == 34) {
                    to_print[index] = yytext[i];
                    index++;
                } else if (yytext[i] == 'n') {
                    to_print[index] = 10;
                    index++;

                } else if (yytext[i] == 'r') {
                    to_print[index] = 13;
                    index++;

                } else if (yytext[i] == 't') {
                    to_print[index] = 9;
                    index++;

                } else if (yytext[i] == '0') {
                    to_print[index] = 0;
                    index++;

                } else if (yytext[i] == 'x') {
                    // handle digits for the \x case
                    if(i+2>=length - 1){
                        if(i+1>=length -1)
                            printf("Error undefined escape sequence %c\n", yytext[i]);
                        else printf("Error undefined escape sequence %c%c\n", yytext[i],yytext[i+1]);
                        exit(0);
                    }
                    else{
                        char first_dig = yytext[i+1];
                        char sec_dig = yytext[i+2];
                        if(first_dig >= '0' &&first_dig <= '7' && ((sec_dig >= '0' && sec_dig <= '9') || (sec_dig >= 'a' && sec_dig <= 'f') || (sec_dig >= 'A' && sec_dig <= 'F')))
                        {
                            i+=2;
                            int first = (first_dig -'0')*16;
                            int second;
                            if(sec_dig >= '0' && sec_dig <= '9') second = sec_dig -'0';
                            else if (sec_dig >= 'a' && sec_dig <= 'f') second = sec_dig - 'a' +10;
                            else if (sec_dig >= 'A' && sec_dig <= 'F') second = sec_dig - 'A' +10;
                            to_print[index] = first+second;
                            index++;
                        }
                        else{
                            printf("Error undefined escape sequence %c%c%c\n", yytext[i],yytext[i+1],yytext[i+2]);
                            exit(0);
                        }

                    }
                }

                 else {
                    printf("Error undefined escape sequence %c\n", yytext[i]);
                    exit(0);

                }
            }
            else{
                if (yytext[i] == 92) {
                    prev_is_backslash = true;
                } else {
                    prev_is_backslash = false;
                    to_print[index] = yytext[i];
                    index++;
                }
            }
        }
        if(prev_is_backslash)
        {
            printf("Error unclosed string\n");
            exit(0);
        }
        printf("%d ", yylineno);
        printf("%s ", name);

        to_print[index]= 0;
        printf("%s\n", to_print);
    }
    else{
        printf("%d ", yylineno);
        printf("%s ", name);
        printf("%s\n", yytext);
        return;
    }
}