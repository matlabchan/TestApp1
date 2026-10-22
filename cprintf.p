function charCount = cprintf(style,format,varargin) %#ok<*JAPIMATHWORKS,*MIPKG,*FEATUD>
% CPRINTF displays styled formatted text in the Command Window
%
% Syntax:
%    count = cprintf(style,format,...)
%
% Description:
%    CPRINTF processes the specified text using the exact same FORMAT
%    arguments accepted by the built-in SPRINTF and FPRINTF functions.
%
%    CPRINTF then displays the text in the Command Window using the
%    specified STYLE argument. The accepted styles are those used for
%    Matlab's syntax highlighting (see: File / Preferences / Colors / 
%    M-file Syntax Highlighting Colors), and also user-defined colors.
%
%    The possible pre-defined STYLE names are (case-insensitive):
%
%      'Text'                - default (based on Preferences): black
%      'Keywords'            - default (based on Preferences): blue
%      'Comments'            - default (based on Preferences): green
%      'Strings'             - default (based on Preferences): purple
%      'UnterminatedStrings' - default (based on Preferences): dark red
%      'SystemCommands'      - default (based on Preferences): orange
%      'Errors'              - default (based on Preferences): light red
%      'Hyperlinks'          - default (based on Preferences): blue (underlined)
%
%      'Black','Cyan','Magenta','Blue','Green','Red','Yellow','White',
%      'Gray','Orange','Pink','Silver','Maroon','Purple','Olive','Navy',
%      'Teal','Violet','Rose','Brown','Indigo','Gold','Wheat'
%       ...and also variants of these colors using a 'light' or 'dark' prefix.
%       For example: 'light-gray', 'darkGreen'
%
%    STYLE is case-insensitive and accepts unique (non-ambiguous) partial strings
%       For example: 'cy' [instead of 'cyan'], 'system', 'err'.
%
%    STYLE custom colors can be specified in 3 variants:
%       [0.1,0.7,0.3] - standard Matlab RGB color format (range: 0.0-1.0)
%       [26, 178, 76] - numeric RGB values (range: 0-255)
%       '#1ab34d'     - Hexadecimal format (range: '00'-'FF', case insensitive)
%                       3-digit HTML format is also accepted: 'a5f'='aa55ff'
%
%    STYLE beginning with '-' or '_' will be underlined.
%       For example: '-Blue', '_Comments', '-#0FF', -[0,1,1]
%
%    STYLE beginning with '~' will be strike-through (on R2026a+ only).
%       For example: '~Blue', '~Comments', '~#0FF', ~[0,1,1]
%
%    STYLE beginning with '/' will be italic (on R2026a+ only).
%       For example: '/Blue', '/Comments', '/#0FF', /~[0,1,1]
%
%    STYLE beginning with '*' will be bold (on R2011b+ only).
%       For example: '*Blue', '*Comments', '*#F00', '*[1,0,0]'
%       Bold & underline can be combined, for example: '*_red' or '_*blue'
%
%    CPRINTF by itself, without any input parameters, displays the usage demo
%
% Usage examples:
%    cprintf;   % displays the usage demo
%    cprintf('text',       'regular black text');
%    cprintf('hyper',      'followed %s','by');
%    cprintf('key',        '%d colored', 8);
%    cprintf('~pink',      'strike-through');
%    cprintf('/purple',    'italic');
%    cprintf('-comment',   'and underlined');
%    cprintf('err',        'elements:\n');
%    cprintf('cyan',       'cyan ');
%    cprintf('_green',     'underlined green ');
%    cprintf('lightgreen', 'light green ');
%    cprintf('dark-green', 'dark green ');
%    cprintf('#800080',    'any custom RGB ');
%    cprintf([1,0.5,0],    'multi-\nline orange ');
%    cprintf(-[1,0,1],     'underlined magenta\n');
%    cprintf('*blue',      'and *bold* (R2011b+) ');
%    cprintf('*_red',      'and *bold underline* (R2011b+)\n');
%
%    cprintf('string');  % same as fprintf('string') and cprintf('text','string')
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 7+, but use at your own risk!
%
%    A technical description of the implementation can be found at:
%    <a href="http://undocumentedmatlab.com/articles/cprintf">http://UndocumentedMatlab.com/articles/cprintf</a>
%
% Limitations:
%    1. In R2011a and earlier, a single space char is inserted at the
%       beginning of each CPRINTF text segment (this is ok in R2011b+).
%
%    2. In R2011a and earlier, consecutive differently-colored multi-line
%       CPRINTFs sometimes display incorrectly on the bottom line.
%       As far as I could tell this is due to a Matlab bug. Examples:
%         >> cprintf('-str','under\nline'); cprintf('err','red\n'); % hidden 'red', non-hidden '_'
%         >> cprintf('str','regu\nlar');    cprintf('err','red\n'); % underline red (not purple) 'lar'
%
%    3. Sometimes, non newline ('\n')-terminated segments display unstyled
%       (black) when the command prompt chevron ('>>') regains focus on the
%       continuation of that line (I can't pinpoint when this happens). 
%       To fix this, simply newline-terminate all command-prompt messages.
%
%    4. In R2011b and later, the above errors appear to be fixed. However,
%       the last character of an underlined segment is not underlined for
%       some unknown reason (add an extra space character to make it look better)
%
%    5. In old Matlab versions (e.g., Matlab 7.1 R14), multi-line styles
%       only affect the first line. Single-line styles work as expected.
%       R14 also appends a single space after underlined segments.
%
%    6. Bold style is only supported on R2011b+ (can be combined with underline).
%
%    7. CPRINTF is not supported in Matlab mobile, Live Editor, deployed, diary,
%       and terminal (no desktop) modes; The new web-based (JavaScript) desktop
%       is only supported in R2025a or newer. This limitation depends on internal
%       Matlab limitations that may possibly be lifted in future Matlab releases.
%
%    8. On R2025a or newer, HTML hyperlinks cannot have a non-default style.
%
% See also:
%    sprintf, fprintf

% Change log:
%    2009-05-13: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
%    2009-05-28: corrected nargout behavior suggested by Andreas Gäb
%    2009-09-28: Fixed edge-case problem reported by Swagat K
%    2010-06-27: Fix for R2010a/b; fixed edge case reported by Sharron; CPRINTF with no args runs the demo
%    2011-03-04: Performance improvement
%    2011-08-29: Fix by Danilo (FEX comment) for non-default text colors
%    2011-11-27: Fixes for R2011b
%    2012-08-06: Fixes for R2012b; added bold style; accept RGB string (non-numeric) style
%    2012-08-09: Graceful degradation support for deployed (compiled) and non-desktop applications; minor bug fixes
%    2015-03-20: Fix: if command window isn't defined yet (startup) use standard fprintf as suggested by John Marozas
%    2015-06-24: Fixed a few discoloration issues (some other issues still remain)
%    2020-01-20: Fix by T. Hosman for embedded hyperlinks
%    2021-04-07: Enabled specifying color as #RGB (hexa codes), [.1,.7,.3], [26,178,76]
%    2022-01-04: Fixed cases of invalid colors (especially bad on R2021b onward)
%    2022-03-26: Fixed cases of using string (not char) inputs
%    2025-02-12: Support R2025a (web-based desktop)
%    2025-03-05: Output to STDERR if style is 'error','red' or [1,0,0] (non-Desktop modes only)
%    2025-09-07: Fixed auto-hyperlink in R2025a+; empty style now means 'text'
%    2025-09-08: Fixed "stuck" color styling in case of invalid escape sequence reported by Alex N
%    2026-02-02: Workaround for hyperlink style on Javascript & online desktops reported by Meike
%    2026-04-20: Added predefined color names & Dark/Light variants, updated demo
%    2026-04-22: Added several predefined named colors; reverted unnecessary R2026a fix
%    2026-06-26: Added ability for concurrent bold & underline (thanks @SongYuxuan)
%    2026-10-12: Added italic & strike-through modes (R2026a+); removed p-code code obfuscation

% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.23 $  $Date: 2026/10/12 19:46:00 $

  persistent majorVersion minorVersion
  if isempty(majorVersion)
      %v = version; if str2double(v(1:3)) <= 7.1
      %majorVersion = str2double(regexprep(version,'^(\d+).*','$1'));
      %minorVersion = str2double(regexprep(version,'^\d+\.(\d+).*','$1'));
      %[a,b,c,d,versionIdStrs]=regexp(version,'^(\d+)\.(\d+).*');  %#ok unused
      v = sscanf(version, '%d.', 2);
      majorVersion = v(1); %str2double(versionIdStrs{1}{1});
      minorVersion = v(2); %str2double(versionIdStrs{1}{2});
  end

  % The following is for debug use only:
  %global docElement el debugData
  if ~exist('el','var') || isempty(el),  el=handle([]);  end  %#ok mlint short-circuit error ("used before defined")
  if nargin<1, showDemo(majorVersion,minorVersion); return;  end
  if isempty(style), style = 'text'; end
  if isa(style,'string'), style = char(style); end
  if all(ishandle(style)) && length(style)~=3
      dumpElement(style);
      return;
  end

  % Process the text string
  if nargin<2, format = style; style='text';  end
  if isa(format,'string'), format = char(format); end
  %error(nargchk(2, inf, nargin, 'struct'));
  %str = sprintf(format,varargin{:});

  % Bypass styling in deployed/nodesktop/LiveEditor/Diary/online/mobile modes
  try
      % matlab.desktop.internal.webdesktop('-inuse')
      useDesktop = desktop('-inuse');
  catch
      try
          % com.mathworks.mde.desk.MLDesktop.getInstance.hasMainFrame
          useDesktop = usejava('desktop');
      catch
          useDesktop = false;
      end
  end
  try isOnline = matlab.internal.web.isMatlabOnlineEnv(); catch, isOnline = false; end
  try isMobile = matlab.internal.web.isMatlabMobile();    catch, isMobile = false; end
  try isWebUI  = feature('webui');             catch, isWebUI  = false; end
  try isLiveEd = feature('LiveEditorRunning'); catch, isLiveEd = false; end
  isJSD = isOnline || isWebUI;
  isR25plus = majorVersion >= 25;
  isR26plus = majorVersion >= 26; %#ok<NASGU>

  persistent diaryWarned
  if isempty(diaryWarned), diaryWarned = false; end
  try isDiary  = strcmp(get(0,'Diary'), 'on'); catch, isDiary  = false; end
  if isDiary && ~diaryWarned
      warning('YMA:cprintf:diary','cprintf formatting is not displayed when diary is active');
      diaryWarned = true;
  end

  useBypass = isdeployed || ~useDesktop || isMobile || isLiveEd || isDiary || ...
      (~isR25plus && isJSD) || (isR25plus && contains(lower(format),'<a href'));

  useANSI = ~useBypass && isR25plus && isJSD;

  if useBypass
      % do not display any formatting - use simple fprintf()
      % See: http://undocumentedmatlab.com/blog/bold-color-text-in-the-command-window/#comment-103035
      % See: https://mail.google.com/mail/u/0/#inbox/FMfcgzQXJszvfxGcXbWSBqSdbXfpSFdB
      % Also see: https://mail.google.com/mail/u/0/?ui=2&shva=1#all/1390a26e7ef4aa4d
      % Also see: https://mail.google.com/mail/u/0/?ui=2&shva=1#all/13a6ed3223333b21
      if (ischar(style) && any(strncmpi(style,{'red','err'},3))) || ...
         (numel(style)>2 && isequal(style(2:3),[0,0]))
          count1 = fprintf(2,format,varargin{:});
      else
          count1 = fprintf(format,varargin{:});
      end
  else
      % Else (Matlab desktop mode)
      % Get the normalized style name and underlining flag
      [style, attrs, debugFlag] = processStyleInfo(style,useANSI);
      isUnderline = attrs.isUnderline;
      isStrike    = attrs.isStrike;
      isItalic    = attrs.isItalic;
      isBold      = attrs.isBold;

      % If using ANSI (R2025a+)
      if useANSI

          % Count the number of characters before adding ANSI control chars
          % Note: supress BadEscape warning: will be displayed by fprintf() below
          oldWarn = warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
          text = sprintf(format, varargin{:});
          count1 = length(text);  % count the chars *before* formatting
          warning(oldWarn);
          str = format;

          % Add the necessary ANSI control chars to the requested text
          textColor = getColorPref('ColorsText', [0,0,0]); %black
          if ~isequal(style,textColor) %|| isBold || isUnderline
              style = sprintf('%d;%d;%d', style(1:3)); %RGB color
              if isBold,      style = [style ';1']; end  %bold
              if isItalic,    style = [style ';3']; end  %italic (R2026a+)
              if isStrike,    style = [style ';9']; end  %strike-through (R2026a+)
              if isUnderline, style = [style ';4']; end  %underline

              % Finish styling, then add the original string to print
              str = ['\x1b[38;2;' style 'm' str];

              % Reset ANSI style even if fprintf() croaks (bug reported 7/9/25 by Alexander Nezhin)
              hCleanup = onCleanup(@() fprintf('\x1b[0m'));

              % Fix \n problem on R2026a+ - Yu Li 25/3/26 - UNDO!!! 22/4/26
              %https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-command-window?tab=discussions#discussions_2624049
              %if isR26plus, str = strrep(str,'\n','\n\n'); end
          else  % plain black text - bypass (no ANSI control chars)
              % no ANSI style applied!
          end

          % Output the text with the possibly-added ANSI control chars
          fprintf(str, varargin{:});

      % Else (Java Desktop)
      else

          % Set hyperlinking, if so requested (using a no-target hyperlink hack)
          if isUnderline
              prefix = '<a href="">';
              if isBold, prefix = '<a href="" style="font-weight:bold">'; end  % @SongYuxuan 26/6/26
              %format = [prefix format '</a>'];  % this displayed incorrectly for embedded hyperlinks

              % Handle case of embedded hyperlinks with underline format 5/1/2020
              str = sprintf(format, varargin{:});
              str = regexprep(str,{'<a ','/a>','_@@@_'},{'_@@@_<a ',['/a>' prefix],'</a>'},'ignorecase');
              str = [prefix str '</a>'];
              format = '%s'; varargin = {str};

              % Matlab 7.1 R14 (possibly a few newer versions as well?)
              % have a bug in rendering consecutive hyperlinks
              % This is fixed by appending a single non-linked space
              if majorVersion < 7 || (majorVersion==7 && minorVersion <= 1)
                  format(end+1) = ' ';
              end
          %end

          % Set bold, if requested and supported (R2011b+)
          elseif isBold
              if (majorVersion > 7 || minorVersion >= 13)
                  format = ['<strong>' format '</strong>'];
              else
                  isBold = 0;
              end
          end

          % Get the current CW position
          cmdWinDoc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance;
          lastPos = cmdWinDoc.getLength;

          % If not beginning of line
          bolFlag = 0;  %#ok
          %if docElement.getEndOffset - docElement.getStartOffset > 1
          % Display a hyperlink element in order to force element separation
          % (otherwise adjacent elements on the same line will be merged)
          if majorVersion<7 || (majorVersion==7 && minorVersion<13)
              if ~isUnderline
                  fprintf('<a href=""> </a>');  %fprintf('<a href=""> </a>\b');
              elseif format(end)~=10  % if no newline at end
                  fprintf(' ');  %fprintf(' \b');
              end
          end
          %drawnow;
          bolFlag = 1;
          %end

          % Get a handle to the Command Window component
          mde = com.mathworks.mde.desk.MLDesktop.getInstance;
          cw = mde.getClient('Command Window');

          % Fix: if command window isn't defined yet (startup), use standard fprintf()
          if (isempty(cw))
              count1 = fprintf(format,varargin{:});
              if nargout
                  charCount = count1;
              end
              return;
          end

          xCmdWndView = cw.getComponent(0).getViewport.getComponent(0);

          % Store the CW background color as a special color pref
          % This way, if the CW bg color changes (via File/Preferences),
          % it will also affect existing rendered strs
          com.mathworks.services.Prefs.setColorPref('CW_BG_Color',xCmdWndView.getBackground);

          % Display the text in the Command Window
          % Note: fprintf(2,...) is required in order to add formatting tokens, which
          % ^^^^  can then be updated below (no such tokens when outputting to stdout)
          %format(end+1) = ' ';  % Jacob D's FEX comment 14/6/2016 (sometimes makes things worse!) https://mail.google.com/mail/u/0/#inbox/15551268609f9fef
          cmdWinLen = cmdWinDoc.getLength;
          cmdWinLenPrev = cmdWinLen;
          count1 = fprintf(2,format,varargin{:});

          % Repaint the command window (wait a bit for the async update to complete)
          iter = 0;
          while count1 > 0 && cmdWinLen <= cmdWinLenPrev && iter < 100
              %awtinvoke(cmdWinDoc,'remove',lastPos,1);   % TODO: find out how to remove the extra '_'
              drawnow;  % this is necessary for the following to work properly (refer to Evgeny Pr in FEX comment 16/1/2011)
              pause(0.01);
              xCmdWndView.repaint;
              %hListeners = cmdWinDoc.getDocumentListeners; for idx=1:numel(hListeners), try hListeners(idx).repaint; catch, end, end
              cmdWinLen = cmdWinDoc.getLength;
              iter = iter + 1;
          end

          docElement = cmdWinDoc.getParagraphElement(lastPos+1);
          if majorVersion<7 || (majorVersion==7 && minorVersion<13)
              if bolFlag && ~isUnderline
                  % Set the leading hyperlink space character ('_') to the bg color, effectively hiding it
                  % Note: old Matlab versions have a bug in hyperlinks that need to be accounted for...
                  %disp(' '); dumpElement(docElement)
                  setElementStyle(docElement,'CW_BG_Color',1+isUnderline,majorVersion,minorVersion); %+getUrlsFix(docElement));
                  %disp(' '); dumpElement(docElement)
                  el(end+1) = handle(docElement);  % #ok used in debug only
              end

              % Fix a problem with some hidden hyperlinks becoming unhidden...
              fixHyperlink(docElement);
              %dumpElement(docElement);
          end

          % Get the Document Element(s) corresponding to the latest fprintf operation
          %debugData = [iter, count1, lastPos, docElement.getStartOffset, cmdWinLen];
          while docElement.getStartOffset <= cmdWinLen
              % Set the element style according to the current style
              if debugFlag, dumpElement(docElement); end
              specialFlag = isUnderline | isBold;
              setElementStyle(docElement,style,specialFlag,majorVersion,minorVersion);
              if debugFlag, dumpElement(docElement); end
              docElement2 = cmdWinDoc.getParagraphElement(docElement.getEndOffset+1);
              if isequal(docElement,docElement2),  break;  end
              docElement = docElement2;
          end
          if debugFlag, dumpElement(docElement); end

          % Force a Command-Window repaint
          % Note: this is important in case the rendered str was not '\n'-terminated
          xCmdWndView.repaint;
          %fprintf('\b');  % Jacob D's FEX comment 14/6/2016 (sometimes makes things worse!) https://mail.google.com/mail/u/0/#inbox/15551268609f9fef

          % The following is for debug use only:
          el(end+1) = handle(docElement);  %#ok used in debug only
          %elementStart  = docElement.getStartOffset;
          %elementLength = docElement.getEndOffset - elementStart;
          %txt = cmdWinDoc.getText(elementStart,elementLength);
      end
  end

  if nargout
      charCount = count1;
  end
  return;  % debug breakpoint

% Process the requested style information
function [style, attrs, debugFlag] = processStyleInfo(style, useANSI)
  attrs.isUnderline = 0;
  attrs.isStrike = 0;
  attrs.isItalic = 0;
  attrs.isBold = 0;
  debugFlag = 0;
  if nargin < 2, useANSI = false; end

  % First, strip out the underline/bold markers
  if ischar(style)
      % Check for bold mode (style contains '*')
      boldIdx = (style=='*');
      if any(boldIdx)
          attrs.isBold = 1;
          style = style(~boldIdx);
      end

      % Check for strike-through mode (style contains '~')
      strikeIdx = (style=='~');
      if ~isempty(strikeIdx) && strikeIdx(1) %any(strikeIdx)
          attrs.isStrike = 1;
          style = style(~strikeIdx);
          %style = style(2:end);
      end

      % Check for underline mode (style starts with '/')
      %if style(1)=='/'
      italicIdx = (style=='/');
      if ~isempty(italicIdx) && italicIdx(1) %any(italicIdx)
          attrs.isItalic = 1;
          %style = style(~italicIdx);
          style = style(2:end);
      end

      % Check for underline mode (style starts with '-' or '_')
      %if style(1)=='-'
      underlineIdx = (style=='-') | (style=='_');
      if ~isempty(underlineIdx) && underlineIdx(1) %any(underlineIdx)
          attrs.isUnderline = 1;
          %style = style(~underlineIdx);
          style = style(2:end);
      end

      %{
      % Prevent bold+underline on non-ANSI desktops (pre-25a or non-JSD)
      % Yair 26/6/26: this limitation fixed thanks to @SongYuxuan's CSS tip on FEX
      if isUnderline && isBold && ~useANSI
          verStr = ver('MATLAB').Release;
          msg = ['Your Matlab release ' verStr ' does not support using bold & underline style together'];
          warning('YMA:cprintf:BoldUnderline',msg);
      end
      %}

      % Check for debug mode (style contains '!')
      debugIdx = (style=='!');
      if any(debugIdx)
          debugFlag = 1;
          style = style(~debugIdx);
      end

      % Check if the remaining style sting is a numeric vector
      %styleNum = str2num(style); %#ok<ST2NM>  % not good because style='text' is evaled!
      %if ~isempty(styleNum)
      if any(style==' ' | style==',' | style==';')
          style = str2num(style); %#ok<ST2NM>
      end
  end

  % Empty style = 'text'
  if isempty(style), style = 'text'; end

  % Style = valid matlab RGB vector: [0.1,0.2,0.3] or [25,50,75]
  if isnumeric(style) && length(style)==3 && all(style<=255) && all(abs(style)>=0)
      if any(style<0)
          attrs.isUnderline = 1;
          style = abs(style);
      end
      style = fix(style * 255);
      if ~useANSI, style = getColorStyle(style); end

  elseif ~ischar(style)
      error('YMA:cprintf:InvalidStyle','Invalid style - see the <a href="matlab:helpPopup(''cprintf'')">cprintf help section</a> for a list of valid style values')

  % #RGB in hex mode (suggested by Andres Tönnesmann 26/3/21 https://mail.google.com/mail/u/0/#inbox/FMfcgxwLtGlbzftbfKJwWLNZKpSqzHhR)
  elseif style(1) == '#'
      hexCode = style(2:min(end,7));
      if length(hexCode)==3, hexCode = reshape([hexCode;hexCode],1,[]); end  % #a5f -> #aa55ff
      hexCode = sprintf('%06s',hexCode);  % pad with leading 00s
      hexCode = reshape(hexCode,2,3)';  % '1a2b3c' -> ['1a'; '2b'; '3c']
      style = hex2dec(hexCode);  % convert to [r,g,b] tripplet (0-255 values)
      if ~useANSI, style = getColorStyle(style); end

  % Style name
  else
      % Try case-insensitive partial/full match with the accepted style names
      matlabStyles = {'Text', 'Keywords', 'Comments', 'Strings', ...
                      'UnterminatedStrings', 'SystemCommands', 'Errors'};
      matlabColors = [0,0,0; 0,0,1; .133,.0545,.133; 1,0,1; 1,0,0; 1,1,0; 1,0,0];
      validStyles  = [matlabStyles, ...
                      'Black','Cyan','Magenta','Blue','Green','Red','Yellow','White', ...
                      'Gray','Orange','Pink', ... % java.awt.Color static colors
                      'Silver','Maroon','Purple','Olive','Navy','Teal',... % HTML 4 colors
                      'Violet','Rose','Brown','Indigo','Gold','Wheat', ... % a few extra
                      'Hyperlinks'];
      style = regexprep(style,'grey',   'gray',   'ignorecase'); %synonyms
      style = regexprep(style,'aqua',   'cyan',   'ignorecase'); %synonyms
      style = regexprep(style,'lime',   'green',  'ignorecase'); %synonyms
      style = regexprep(style,'fuchsia','magenta','ignorecase'); %synonyms
      style = regexprep(style,'[_-]',''); %dark-gray => darkgray
      isLight = ~isempty(strfind(lower(style), 'light')); %#ok<STREMP>
      isDark  = ~isempty(strfind(lower(style), 'dark'));  %#ok<STREMP>
      style = regexprep(style,'light|dark','');
      matches = find(strncmpi(style,validStyles,length(style)));

      % No match - error
      if isempty(matches)
          error('YMA:cprintf:InvalidStyle','Invalid style - see the <a href="matlab:helpPopup(''cprintf'')">cprintf help section</a> for a list of valid style values')

      % Too many matches (ambiguous) - error
      elseif length(matches) > 1
          error('YMA:cprintf:AmbigStyle','Ambiguous cprintf style name - supply extra characters for uniqueness')

      % Regular text
      elseif matches == 1
          style = 'ColorsText';  % fixed by Danilo, 29/8/2011
          if useANSI %JSD
              style = getColorPref(style, [0,0,0]); %black
          end

      % Highlight preference style name
      elseif matches <= length(matlabStyles)
          style = ['Colors_M_' validStyles{matches}];
          if useANSI %JSD
              style = getColorPref(style, matlabColors(matches,:));
          end

      % Color name
      elseif matches < length(validStyles)
          colors = [0,0,0; 0,1,1; 1,0,1; 0,0,1; ...     % Black,Cyan,Magenta,Blue
                    0,1,0; 1,0,0; 1,1,0; 1,1,1; ...     % Green,Red,Yellow,White
                    .5,.5,.5;    1,.5,0; 1,.68,.68; ... % Gray,Orange,Pink
                    .75,.75,.75; .5,0,0; .5,0,.5;   ... % Silver,Maroon,Purple
                    .5,.5,0;     0,0,.5; 0,.5,.5;   ... % Olive,Navy,Teal
                    1,.5,1;      1,0,.5; .5,.25,.1; ... % Violet,Rose,Brown
                    .25,0,.5;    1,.84,0; 1,.85,.7; ... % Indigo,Gold,Wheat
                   ];
          style = colors(matches-length(matlabStyles),:); %[r,g,b]
          if isLight
              style = 0.5*style + [.5,.5,.5];  % 0.5 => 0.75
          elseif isDark
              style = 0.5*style;               % 0.5 => 0.25
          end
          style = round(style*255);
          if ~useANSI, style = getColorStyle(style); end

      % Hyperlink
      else
          style = 'Colors_HTML_HTMLLinks';  % CWLink
          if useANSI %JSD
              style = getColorPref(style, [0,0,1]); %blue
          end
          attrs.isUnderline = 1;
      end
  end

% Get color preferences (if available) as [r,g,b] (0-255 values)
function rgb = getColorPref(styleName, default)
    try
        % TODO: check settings (root.matlab.colors.KeywordColor etc.)
        rgb = com.mathworks.services.Prefs.getColorPref(styleName);
        rgb = fix(255*double(rgb.getColorComponents([])))';
    catch
        rgb = default;
    end

% Convert a Matlab RGB vector into a known style name (e.g., '[255,37,0]')
function styleName = getColorStyle(rgb)
  if all(rgb<=1), rgb = rgb*255; end  % 0.5 -> 127
  intColor = int32(rgb);
  javaColor = java.awt.Color(intColor(1), intColor(2), intColor(3));
  styleName = sprintf('[%d,%d,%d]',intColor);
  com.mathworks.services.Prefs.setColorPref(styleName,javaColor);

% Fix a bug in some Matlab versions, where the number of URL segments
% is larger than the number of style segments in a doc element
function delta = getUrlsFix(docElement)  %currently unused
  tokens = docElement.getAttribute('SyntaxTokens');
  links  = docElement.getAttribute('LinkStartTokens');
  if length(links) > length(tokens(1))
      delta = length(links) > length(tokens(1));
  else
      delta = 0;
  end

% fprintf(2,str) causes all previous '_'s in the line to become red - fix this
function fixHyperlink(docElement)
  try
      tokens = docElement.getAttribute('SyntaxTokens');
      urls   = docElement.getAttribute('HtmlLink');
      urls   = urls(2);
      links  = docElement.getAttribute('LinkStartTokens');
      offsets = tokens(1);
      styles  = tokens(2);
      doc = docElement.getDocument;

      % Loop over all segments in this docElement
      for idx = 1 : length(offsets)-1
          % If this is a hyperlink with no URL target and starts with ' ' and is collored as an error (red)...
          if strcmp(styles(idx).char,'Colors_M_Errors')
              character = char(doc.getText(offsets(idx)+docElement.getStartOffset,1));
              if strcmp(character,' ')
                  if isempty(urls(idx)) && links(idx)==0
                      % Revert the style color to the CW background color (i.e., hide it!)
                      styles(idx) = java.lang.String('CW_BG_Color');
                  end
              end
          end
      end
  catch
      % never mind...
  end

% Set an element to a particular style (color)
function setElementStyle(docElement,style,specialFlag, majorVersion,minorVersion)
  %global tokens links urls urlTargets  % for debug only
  global oldStyles %#ok<GVMIS>
  if nargin<3,  specialFlag=0;  end
  % Set the last Element token to the requested style:
  % Colors:
  tokens = docElement.getAttribute('SyntaxTokens');
  try
      styles = tokens(2);
      oldStyles{end+1} = cell(styles);

      % Correct edge case problem
      extraInd = double(majorVersion>7 || (majorVersion==7 && minorVersion>=13));  % =0 for R2011a-, =1 for R2011b+
      %{
      if ~strcmp('CWLink',char(styles(end-hyperlinkFlag))) && ...
          strcmp('CWLink',char(styles(end-hyperlinkFlag-1)))
         extraInd = 0;%1;
      end
      hyperlinkFlag = ~isempty(strmatch('CWLink',tokens(2)));
      hyperlinkFlag = 0 + any(cellfun(@(c)(~isempty(c)&&strcmp(c,'CWLink')),cell(tokens(2))));
      %}

      jStyle = java.lang.String(style);
      if numel(styles)==4 && isempty(char(styles(2)))
          % Attempt to fix discoloration issues - NOT SURE THAT THIS IS OK! - 24/6/2015
          styles(1) = jStyle;
      end
      styles(end-extraInd) = java.lang.String('');
      styles(end-extraInd-specialFlag) = jStyle;  % #ok apparently unused but in reality used by Java
      if extraInd
          styles(end-specialFlag) = jStyle;
      end

      oldStyles{end} = [oldStyles{end} cell(styles)];
  catch
      % never mind for now
  end
  
  % Underlines (hyperlinks):
  %{
  links = docElement.getAttribute('LinkStartTokens');
  if isempty(links)
      %docElement.addAttribute('LinkStartTokens',repmat(int32(-1),length(tokens(2)),1));
  else
      %TODO: remove hyperlink by setting the value to -1
  end
  %}

  % Correct empty URLs to be un-hyperlinkable (only underlined)
  urls = docElement.getAttribute('HtmlLink');
  if ~isempty(urls)
      urlTargets = urls(2);
      for urlIdx = 1 : length(urlTargets)
          try
              if urlTargets(urlIdx).length < 1
                  urlTargets(urlIdx) = [];  % '' => []
              else  % fix for hyperlinks by T. Hosman 25/11/2019 (via email)
                  if urlIdx > 1
                      styles(urlIdx-1) = jStyle;
                  end
                  styles(urlIdx) = jStyle; %=java.lang.String('CWLink');
              end
          catch
              % never mind...
              a=1;  %#ok used for debug breakpoint...
          end
      end
  end
  
  % Bold: (currently unused because we cannot modify this immutable int32 numeric array)
  %{
  try
      %hasBold = docElement.isDefined('BoldStartTokens');
      bolds = docElement.getAttribute('BoldStartTokens');
      if ~isempty(bolds)
          %docElement.addAttribute('BoldStartTokens',repmat(int32(1),length(bolds),1));
      end
  catch
      % never mind - ignore...
      a=1;  %#ok used for debug breakpoint...
  end
  %}
  
  return;  % debug breakpoint

% Display information about element(s)
function dumpElement(docElements)
  %return;
  disp(' ');
  numElements = length(docElements);
  cmdWinDoc = docElements(1).getDocument;
  for elementIdx = 1 : numElements
      if numElements > 1,  fprintf('Element #%d:\n',elementIdx);  end
      docElement = docElements(elementIdx);
      if ~isjava(docElement),  docElement = docElement.java;  end
      %docElement.dump(java.lang.System.out,1)
      disp(strtrim(char(docElement)))
      txt = {};
      try
          tokens = docElement.getAttribute('SyntaxTokens');
          %if isempty(tokens),  continue;  end
          links = docElement.getAttribute('LinkStartTokens');
          urls  = docElement.getAttribute('HtmlLink');
          try bolds = docElement.getAttribute('BoldStartTokens'); catch, bolds = []; end
          tokenLengths = tokens(1);
          for tokenIdx = 1 : length(tokenLengths)-1
              tokenLength = diff(tokenLengths(tokenIdx+[0,1]));
              if (tokenLength < 0)
                  tokenLength = docElement.getEndOffset - docElement.getStartOffset - tokenLengths(tokenIdx);
              end
              txt{tokenIdx} = cmdWinDoc.getText(docElement.getStartOffset+tokenLengths(tokenIdx),tokenLength).char;  %#ok
          end
      catch
          tokenLengths = 0;
      end
      lastTokenStartOffset = docElement.getStartOffset + tokenLengths(end);
      try
          txt{end+1} = cmdWinDoc.getText(lastTokenStartOffset, docElement.getEndOffset-lastTokenStartOffset).char; %#ok
      catch
          txt{end+1} = ''; %#ok<AGROW>
      end
      %cmdWinDoc.uiinspect
      %docElement.uiinspect
      txt = strrep(txt',sprintf('\n'),'\n'); %#ok<SPRINTFN>
      try
          data = [cell(tokens(2)) m2c(tokens(1)) m2c(links) m2c(urls(1)) cell(urls(2)) m2c(bolds) txt];
          if elementIdx==1
              disp('    SyntaxTokens(2,1) - LinkStartTokens - HtmlLink(1,2) - BoldStartTokens - txt');
              disp('    ==============================================================================');
          end
      catch
          try
              data = [cell(tokens(2)) m2c(tokens(1)) m2c(links) txt];
          catch
              try
                  disp([cell(tokens(2)) m2c(tokens(1)) txt]);
                  data = [m2c(links) m2c(urls(1)) cell(urls(2))];
              catch
                  % Matlab 7.1 only has urls(1)...
                  try
                      data = [m2c(links) cell(urls)];
                  catch  % no tokens
                      data = txt;
                  end
              end
          end
      end
      disp(data)
  end

% Utility function to convert matrix => cell
function cells = m2c(data)
  %datasize = size(data);  cells = mat2cell(data,ones(1,datasize(1)),ones(1,datasize(2)));
  cells = num2cell(data);

% Display the help and demo
function showDemo(majorVersion,minorVersion)
  fprintf('cprintf displays formatted text in the Command Window.\n\n');
  fprintf('Syntax: count = cprintf(style,format,...);  click <a href="matlab:help cprintf">here</a> for details.\n\n');
  url = 'https://UndocumentedMatlab.com/articles/cprintf';
  fprintf(['Technical description: <a href="' url '">' url '</a>\n\n']);
  fprintf('Demo:\n\n');
  isBold = majorVersion>7 || (majorVersion==7 && minorVersion>=13);
  s = ['cprintf(''text'',      ''regular black text'');' 10 ...
       'cprintf(''hyper'',     ''followed %s'',''by'');' 10 ...
       'cprintf(''key'',       ''%d colored '',' num2str(7+isBold) ');' 10 ...
       'cprintf(''~pink'',     ''strike-through'');' 10 ...
       'cprintf(''/purple'',   ''italic'');' 10 ...
       'cprintf(''-comment'',  ''and underlined'');' 10 ...
       'cprintf(''err'',       ''elements:\n'');' 10 ...
       'cprintf(''cyan'',      ''cyan'');' 10 ...
       'cprintf(''_green'',    ''underlined green'');' 10 ...
       'cprintf(''lightgreen'',''light green'');' 10 ...
       'cprintf(''dark-green'',''dark green'');' 10 ...
       'cprintf(''#800080'',   ''any custom RGB'');' 10 ...
       'cprintf([1,0.5,0],   ''multi-\nline orange'');' 10 ...
       'cprintf(-[1,0,1],    ''underlined magenta\n'');' 10 ...
       ];
   if isBold
       % In R2011b+ the internal bug that causes the need for an extra space
       % is apparently fixed, so we must insert the separator spaces manually...
       % On the other hand, R2011b enables *bold* format
       s = [s 'cprintf(''*blue'',     ''and *bold* (R2011b+)'');' 10];
       s = [s 'cprintf(''*_red'',     ''and *bold underline* (R2011b+)\n'');' 10];
       s = strrep(s, ''')',' '')');
       s = strrep(s, ''',5)',' '',5)');
       s = strrep(s, '\n ','\n');
   end
   if majorVersion < 26
       s = regexprep(s,'cprintf(''[~/][^\n]+\n',''); %strike/italic on R2026a+ only
   end
   disp(s);
   eval(s);


%%%%%%%%%%%%%%%%%%%%%%%%%% TODO %%%%%%%%%%%%%%%%%%%%%%%%%
% - Fix: Remove leading space char (hidden underline '_')
% - Fix: Find workaround for multi-line quirks/limitations
% - Fix: Non-\n-terminated segments are displayed as black
% - Fix: Check whether the hyperlink fix for 7.1 is also needed on 7.2 etc.
% - Enh: Add font support