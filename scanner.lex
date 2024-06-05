%{
    /* Declarations section */
    #include <stdio.h>
    #include <stddef.h>
    #include <stdint.h>
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
\n
;                   showToken("SC");
\(                  showToken("LPAREN");
\)                  showToken("RPAREN");
\{                  showToken("LBRACE");
\}                  showToken("RBRACE");
=                   showToken("ASSIGN");
[==|!=|<|>|<=|>=]   showToken("RELOP");
[+|-|*|/]           showToken("BINOP");
\/\/[^\n\r]*        showToken("COMMENT");
[A-Za-z][A-Za-z0-9]* showToken("ID");
[1-9][0-9]*|0       showToken("NUM");
".*"                showToken("STRING");
".*[\n\r]           showToken("STRING_ERROR");
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
        printf("//");
    }
    else if(name=="UNKNOWN"){
        printf("Error %s\n", yytext);
    }
    else if(name=="STRING_ERROR")
    {
        printf("Error unclosed string\n");
    }
    else if(name=="STRING"){
        char* to_print="";
        bool prev_is_backslash = False;
        for (int i=1; i < yytext.length - 1; i++) {
            if (prev_is_backslash) {
                if (yytext[i] == '\' || yytext[i] == '"') {
                    append_char(to_print, yytext[i]);
                } else if (yytext[i] == 'n') {
                    append_char(to_print, 10);
                }
                } else if (yytext[i] == 'r') {
                    append_char(to_print, 13);
                } else if (yytext[i] == 't') {
                    append_char(to_print, 9);
                } else if (yytext[i] == '0') {
                    append_char(to_print, 0);
                } else if (yytext[i] == 'x') {
                    // handle digits for the \x case
                } else {
                    printf("Error undefined escape sequence %c\n", yytext[i]);
                }
            }
            if (yytext[i] == '\') {
                prev_is_backslash = True;
            } else {
                prev_is_backslash = False;
            }
        }


    }
    else{
        printf("%d ", yylineno);
        printf("%s ", name);
        printf("%s\n", yytext);
        return;
    }
}