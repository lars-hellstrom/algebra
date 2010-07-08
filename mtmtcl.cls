
\ProvidesClass{mtmtcl}[2007/10/07]

\LoadClass{tclldoc}[2007/07/01]

\newenvironment{ttdescription}{%
  \description
  \def\makelabel##1{\hspace\labelsep\normalfont\ttfamily ##1}%
}{\enddescription}

\NewDescribeCommand{\defining}{%
   \XD@grab@oarg\XD@grab@sarg{*}\XD@grab@oarg\XD@grab@marg
}{4}{%
   \IndexEntry{%
      \ifx \NoValue#1%
         \LevelSame{\ifx\NoValue#3#4\else#3\fi}%
      \else
         \LevelSorted{#1}{\ifx\NoValue#3#4\else#3\fi}%
      \fi
   }{main}{\thepage}%
   \textbf{#4}%
   \@gobble % Eats \ignorespaces
}

\newcommand*{\APIref}{%
   \XD@grab@arguments\APIref@{%
      \XD@grab@sarg{+}\XD@grab@harmless{}\XD@grab@marg
   }%
}
\def\APIref@#1#2#3{%
   \textnormal{\ttfamily #2}%
   \IndexEntry{%
      \LevelSorted{#2}{\texttt{\TDPrintCharBreakable#2} interface}%
      \LevelSorted{#3}{v\protect\,#3}%
   }{none}{\thepage}%
   \ifx \BooleanFalse#1\else
      \nobreak\ (v\,#3)%
   \fi
}

\newcommand{\OMSref}{%
   \XD@grab@arguments\OMSref@{%
      \XD@grab@sarg{*}\XD@grab@harmless{}\XD@grab@harmless{}%
   }%
}
% #1 is boolean: mark as description in index?
% #2 = cd
% #3 = name
\def\OMSref@#1#2#3{%
%    \textnormal{\texttt{#2}\#\penalty\hyphenpenalty
   \textnormal{\texttt{#3}@\penalty\hyphenpenalty
   \IndexEntry{%
      \LevelSorted{#3}{\texttt{#3} symbol}%
      \LevelSorted{#2}{\texttt{#2} content dictionary}%
   }{\ifx #1\BooleanTrue usage\else none\fi}{\thepage}%
%    \texttt{#3}}%
   \texttt{#2}}%
}


\PageIndex
\CodelineNumbered
\setcounter{IndexColumns}{2}

\newenvironment{procmethod}{%
   \tclsubcommand{method}{submethod}%
}{\endtclsubcommand}

% Also methodproc: Primarily a \tclsubcommand{method}{}, but 
% making an index entry for itself also as a proc?

\def\TD@grab@namespace@oarg#1#2\XD@endgrab{%
   \@ifnextchar[{\TD@grab@namespace@oarg@{#2}}{%
      \protected@edef\@tempa{#1}%
      \toks@=\expandafter{\the\expandafter\toks@ \expandafter{\@tempa}}%
      #2\XD@endgrab
   }%
}
\def\TD@grab@namespace@oarg@#1[#2]{%
   \MakeHarmless\@tempa{#2}%
   \protected@edef\@tempa{%
      \expandafter\TD@convert@colons \@tempa::\relax
   }%
   \toks@=\expandafter{\the\expandafter\toks@ \expandafter{\@tempa}}%
   #1\XD@endgrab
}


  % Arguments:
  % \begin{ensemble}[cmd-namespace]{cmd-name}[ns-tail]
  % The ensemble command is cmd-namespace::cmd-name.
  % The ensemble namespace is cmd-namespace::cmd-name too, 
  % unless there is an ns-tail, in which case it is 
  % cmd-namespace::ns-tail. Either will be overridden by 
  % an explicit \setnamespace in the environment body.
\NewMacroEnvironment*{ensemble}{%
   \TD@grab@namespace@oarg{%
      \ifx\TD@namespace\@empty
         \noexpand\NoValue
      \else
         \TD@namespace
      \fi
   }%
   \XD@grab@harmless\relax
   \TD@grab@namespace@oarg{\noexpand\NoValue}%
}{3}{%
   \XDParToMargin{\MacroFont
      \buildname{#1}{#2} \normalfont (ensemble)}%
}{%
   \TD@main@index{#1}{#2}{ensemble}{}%
}{%
   {\buildname{#1}{#2}}{\texttt{\buildname{#1}{#2}} ensemble}%
}{%
   \def\TDMainIndexBase{\TD@main@index{#1}{#2}{ensemble}}%
   \ifx \NoValue#3%
      \def\TD@namespace{#1\namespaceseparator#2}%
   \else\ifx $#3$%
      \def\TD@namespace{#1}%
   \else
      \def\TD@namespace{#1\namespaceseparator#3}%
   \fi\fi
}%


\NewMacroEnvironment*{ensproc}{%
   \TD@grab@namespace@oarg{\TD@namespace}%
   \XD@grab@harmless\relax
}{2}{% Margin material:
   \XDParToMargin{\MacroFont#2 \normalfont (subcommand)}
}{% Index entries:
   \TDMainIndexBase{\LevelSorted{#2}{\texttt{#2} subcommand}}%
   \TD@main@index{#1}{#2}{proc}{}%
}{\saved@macroname}{}
 % No change in \TDMainIndexBase to allow nesting ensproc environments.

%    % Situation: No explicit namespace argument.
%    % Special default: Name of surrounding ensemble, 
%    % taken from \saved@macroname.
%    % Test: if \saved@macroname={\buildname ...}{...}
%    \expandafter\expandafter\expandafter\expandafter 
%       \expandafter\expandafter\expandafter\ifx
%       \expandafter\expandafter\expandafter\@car 
%          \expandafter\@firstoftwo \saved@macroname \@nil \buildname
%       \@empty
%    % then
%       \expandafter\expandafter\expandafter\TD@builtname
%          \expandafter\@firstoftwo \saved@macroname
%    \else
%       \TD@namespace %Hopefully not too bad.
%    \fi
%    
% \def\TD@builtname#1#2#3{%
%    % #1=\buildname
%    % #2 is namespace parent
%    % #3 is namespace tail
%    #2\namespaceseparator#3%
% }



\RequirePackage{amsmath,amsfonts,amssymb}

% \newcommand{\Z}{\ensuremath{\mathbb{Z}}}
\newcommand{\Z}{\texttt{Z}}

\newcommand*{\mw}[1]{\word{$#1$}}

\providecommand{\Ldash}{---}
\providecommand{\Rdash}{---}
\providecommand{\Dash}{---}

% \newcommand{\splode}{\ensuremath{{\{\mkern-5mu*\mkern-5mu\}}}}
% \newcommand{\splode}{\texttt{\PrintChar{123}*\PrintChar{125}}}
\newcommand{\splode}{\texttt{%
  \PrintChar{123}\kern-0.1em*\kern-0.1em\PrintChar{125}%
}}

\RequirePackage{amsthm}

\theoremstyle{plain}
\newtheorem{theorem}{Theorem}[section]
\theoremstyle{definition}
\newtheorem*{definition}{Definition}
\theoremstyle{remark}
\newtheorem*{remark}{Remark}

\RequirePackage{longtable}


% \newcommand{\mtl}{\texttt{mathematcl}}
\newcommand{\mtl}{\texttt{mtmtcl}}
\newcommand{\Tcl}{\Tcllogo}
\newcommand{\TclObj}{\Tcllogo\_Obj}
\newcommand{\TclObjs}{\TclObj s}

% \def\TeX{%
%    T\kern-.18em%
%    \kern-\fontdimen1\font
%    \lower.5ex\hbox{E}%
%    \kern\fontdimen1\font
%    \kern-.135emX%
%    \@%
% }
\DeclareRobustCommand{\La}{%
   L\kern-.30em%
   \kern 0.8\fontdimen1\font
   {%
      \sbox\z@{T}%
      \vbox to\ht\z@{%
         \hbox{%
            \check@mathfonts
            \dimen@=0.8em%
            \edef\@tempa{\noexpand\fontsize{\strip@pt\dimen@}{\z@}}%
            \@tempa
            \math@fontsfalse\selectfont
            A%
         }%
         \vss
      }%
   }%
   \kern -0.8\fontdimen1\font
   \kern-.15em%
}
% \DeclareRobustCommand{\LaTeX}{\La\TeX}
\newcommand{\AllTeX}{(\La)\TeX}



\endinput

