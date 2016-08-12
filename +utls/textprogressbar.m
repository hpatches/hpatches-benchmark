function upd = textprogressbar(n, varargin)
% UPD = TEXTPROGRESSBAR(N) initializes a text progress bar for monitoring a
% task comprising N steps (e.g., the N rounds of an iteration) in the
% command line. It returns a function handle UPD that is used to update and
% render the progress bar. UPD takes a single argument i <= N which 
% corresponds to the number of tasks completed and renders the progress bar
% accordingly.
%                   
% TEXTPROGRESSBAR(...,'barlength',L) determines the length L of the
% progress bar in number of characters (see 'barsymbol' option). L must be
% a positive integer. 
% (Default value is 20 characters.)
%
% TEXTPROGRESSBAR(...,'updstep',S) determines the minimum number of update
% steps S between consecutive bar re-renderings. The option controls how
% frequently the bar is rendered and in turn controls the computational 
% overhead that the bar rendering incurs to the monitored task. It is
% especially useful when bar is used for loops with large number of rounds
% and short execution time per round.
% (Default value is S=10 steps.)
%
% TEXTPROGRESSBAR(...,'startmsg',str) determines the message string to be
% displayed before the progress bar.
% (Default is str='Completed '.)
%
% TEXTPROGRESSBAR(...,'endmsg',str) determines the message string to be 
% displayed after progress bar when the task is completed.
% (Default is str=' Done.')
%
% TEXTPROGRESSBAR(...,'showremtime',b) logical parameter that controls
% whether an estimate of the remaining time is displayed.
% (Default is b=true.)
%
% TEXTPROGRESSBAR(...,'showbar',b) logical parameter that controls whether
% the progress bar is displayed. (Default is b=true.)
%
% TEXTPROGRESSBAR(...,'showpercentage',b) logical parameter that controls
% whether to display the percentage of completed items.
% (Default is true.)
%
% TEXTPROGRESSBAR(...,'showactualnum',b) logical parameter that controls
% whether to display the actual number of completed items.
% (Default is false.)
%
% TEXTPROGRESSBAR(...,'showfinaltime',b) logical parameter that controls
% whether to display the total run-time when completed.
% (Default is true.)
%
% TEXTPROGRESSBAR(...,'barsymbol',c) determines the symbol (character) to
% be used for the progress bar. c must be a single character.
% (Default is c='='.)
%
% TEXTPROGRESSBAR(...,'emptybarsymbol',c) determines the symbol (character)
% that is used to fill the un-completed part of the progress bar. c must be
% a single character.
% (Default is c=' '.)
%
% Example:
%
%   n = 150;
%   upd = textprogressbar(n);
%   for i = 1:n
%      pause(0.05);
%      upd(i);
%   end


% SOURCE: https://github.com/megasthenis/textprogressbar

    % Default Parameter values:
    defaultbarCharLen = 20;
    defaultUpdStep = 10;
    defaultstartMsg = 'Completed ';
    defaultendMsg = ' Done.';
    defaultShowremTime = true;
    defaultShowBar = true;
    defaultshowPercentage = true;
    defaultshowActualNum = false;
    defaultshowFinalTime = true;
    defaultbarCharSymbol = '=';
    defaultEmptybarCharSymbol = ' ';
    
    % Auxiliary functions for checking parameter values:
    ischarsymbol = @(c) (ischar(c) && length(c) == 1);
    ispositiveint = @(x) (isnumeric(x) && mod(x, 1) == 0 && x > 0);
 
    % Register input parameters:
    p = inputParser;
    addRequired(p,'n', ispositiveint);
    addParameter(p, 'barlength', defaultbarCharLen, ispositiveint)
    addParameter(p, 'updatestep', defaultUpdStep, ispositiveint)
    addParameter(p, 'startmsg', defaultstartMsg, @ischar)
    addParameter(p, 'endmsg', defaultendMsg, @ischar)
    addParameter(p, 'showremtime', defaultShowremTime, @islogical)
    addParameter(p, 'showbar', defaultShowBar, @islogical)
    addParameter(p, 'showpercentage', defaultshowPercentage, @islogical)
    addParameter(p, 'showactualnum', defaultshowActualNum, @islogical)
    addParameter(p, 'showfinaltime', defaultshowFinalTime, @islogical)
    addParameter(p, 'barsymbol', defaultbarCharSymbol, ischarsymbol)
    addParameter(p, 'emptybarsymbol', defaultEmptybarCharSymbol, ischarsymbol)
    
    % Parse input arguments:
    parse(p, n, varargin{:});
    n = p.Results.n;
    barCharLen = p.Results.barlength;
    updStep = p.Results.updatestep;
    startMsg = p.Results.startmsg;
    endMsg = p.Results.endmsg;
    showremTime = p.Results.showremtime;
    showBar = p.Results.showbar;
    showPercentage = p.Results.showpercentage;
    showActualNum = p.Results.showactualnum;
    showFinalTime = p.Results.showfinaltime;
    barCharSymbol = p.Results.barsymbol;
    emptybarCharSymbol = p.Results.emptybarsymbol;
    
    % Initialize progress bar:
    bar = ['[', repmat(emptybarCharSymbol, 1, barCharLen), ']'];
    
    nextRenderPoint = 0;
    startTime = tic;
    
    % Initalize block for actual number of completed items:
    
    ind = 1;
    
    % Start message block:
    startMsgLen = length(startMsg);
    startMsgStart = ind;
    startMsgEnd = startMsgStart + startMsgLen - 1;
    ind = ind + startMsgLen;
    
    % Bar block:
    barLen = length(bar);
    barStart = 0;
    barEnd = 0;
    if showBar
        barStart = ind;
        barEnd = barStart + barLen - 1;
        ind = ind + barLen;
    end
    
    % Actual Num block:
    actualNumDigitLen = numel(num2str(n));
    actualNumFormat = sprintf(' %%%dd/%d', actualNumDigitLen, n);
    actualNumStr = sprintf(actualNumFormat, 0);
    actualNumLen = length(actualNumStr);
    actualNumStart = 0;
    actualNumEnd = 0;
    if showActualNum
        actualNumStart = ind;
        actualNumEnd = actualNumStart + actualNumLen-1;
        ind = ind + actualNumLen;
    end
        
    % Percentage block:
    percentageFormat = sprintf(' %%3d%%%%');
    percentageStr = sprintf(percentageFormat, 0);
    percentageLen = length(percentageStr);
    percentageStart = 0;
    percentageEnd = 0;
    if showPercentage
        percentageStart = ind;
        percentageEnd = percentageStart + percentageLen-1;
        ind = ind + percentageLen;
    end
    
    % Remaining Time block:
    remTimeStr = time2str(Inf);
    remTimeLen = length(remTimeStr);
    remTimeStart = 0;
    remTimeEnd = 0;
    if showremTime
       remTimeStart = ind;
       remTimeEnd = remTimeStart + remTimeLen - 1;
       ind = ind + remTimeLen;
    end
    
    
    % End msg block:
    endMsgLen = length(endMsg);
    if showBar
        endMsgStart = barEnd + 1; % Place end message right after bar;
    else
        endMsgStart = startMsgEnd + 1;
    end
    endMsgEnd = endMsgStart + endMsgLen - 1;
    
    ind = max([ind, endMsgEnd]);
    
    % Determine size of buffer:
    arrayLen = ind - 1;
    array = repmat(' ', 1, arrayLen);
    
    % Initial render:
    array(startMsgStart:startMsgEnd) = sprintf('%s', startMsg);

    delAll = repmat('\b', 1, arrayLen);
    
        % Function to update the status of the progress bar:
        function update(i)
            
            if i < nextRenderPoint
                return;
            end
            if i > 0
                fprintf(delAll);
            end
            %pause(1)
            nextRenderPoint = min([nextRenderPoint + updStep, n]);
            
            if showremTime
                % Delete remaining time block:
                array(remTimeStart:remTimeEnd) = ' ';
            end

            if showPercentage
                % Delete percentage block:
                array(percentageStart:percentageEnd) = ' ';
            end
            
            if showActualNum
                % Delete actual num block:
                array(actualNumStart:actualNumEnd) = ' ';
            end
    
            if showBar
                % Update progress bar (only if needed):
                barsToPrint = floor( i / n * barCharLen );
                bar(2:1+barsToPrint) = barCharSymbol;
                array(barStart:barEnd) = bar;
            end
            
            % Check if done:
            if i >= n
                array(endMsgStart:endMsgEnd) = endMsg;
                array(endMsgEnd+1:end) = ' ';
                
                if showFinalTime
                    finalTimeStr = ...
                        sprintf(' [%d seconds]', round(toc(startTime)));
                    finalTimeLen = length(finalTimeStr);
                    if endMsgEnd + finalTimeLen < arrayLen
                       array(endMsgEnd+1:endMsgEnd+finalTimeLen) = ... 
                           finalTimeStr;
                    else
                       array = [array(1:endMsgEnd), finalTimeStr];
                    end
                end
                
                fprintf('%s', array);
                fprintf('\n');
                return;
            end
            
            if showActualNum
                % Delete actual num block:
                actualNumStr = sprintf(actualNumFormat, i);
                array(actualNumStart:actualNumEnd) = actualNumStr;
            end
            
            if showPercentage
                % Render percentage block:
                percentage = floor(i / n * 100);
                percentageStr = sprintf(percentageFormat, percentage);
                array(percentageStart:percentageEnd) = percentageStr;
            end
                
            % Print remaining time block:
            if showremTime
               t = toc(startTime);
               remTime = t/ i * (n-i);
               remTimeStr = time2str(remTime);
               array(remTimeStart:remTimeEnd) = remTimeStr;
            end
            fprintf('%s', array);
        end
    
    % Do the first render:
    update(0);
    
    upd = @update;
    
end

% Auxiliary functions

function timestr = time2str(t)

    if t == Inf
        timestr = sprintf(' --:--:--');
    else
        [hh, mm, tt] = sec2hhmmss(t);
        timestr = sprintf(' %02d:%02d:%02d', hh, mm, tt);
    end
end

function [hh, mm, ss] = sec2hhmmss(t)
    hh = floor(t / 3600);
    t = t - hh * 3600;
    mm = floor(t / 60);
    ss = round(t - mm * 60);
end