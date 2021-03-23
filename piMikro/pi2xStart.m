% Create serial objects connected to serial COM ports (x-, y-stage)

function pi = pi2xStart(configStages)
% pi.piX = piStart(1);
% pi.piY = piStart(2);

% pi.piX = piStart(2);
% pi.piY = piStart(1);

if nargin < 1
    configStages = 'TAM';
end
configStages = upper(configStages);

switch configStages
    case 'RSOM'
        pi.piY = piStart(6);
        pi.piX = piStart(7);   % input is the port number
    case 'MORSOM'
        pi.piY = piStart(11); % x stage
        pi.piX = piStart(7);   % z stage
    case 'TAM'
        pi.piX = piStart(7);   % x stage
        pi.piY = piStart(8); % y stage
        pi.piZ = piStart(9);   % z stage
    case 'TAM_HYBRID'
        pi.piX = piStart(2);   % x stage
        pi.piY = piStart(4); % y stage
        pi.piZ = piStart(5);   % z stage
    otherwise
        error 'Unknown configuration!\n';
end
        
end
