% Create serial objects connected to serial COM ports (x-, y-stage)

function pi = pi3xStart(configStages)
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
        pi.Y = piStart(6);
        pi.X = piStart(7);   % input is the port number
    case 'MORSOM'
        pi.Y = piStart(11); % x stage
        pi.X = piStart(7);   % z stage
    case 'TAM'
        pi.X = piStart(7);   % x stage
        pi.Y = piStart(8); % y stage
        pi.Z = piStart(9);   % z stage
    case 'TAM_HYBRID'
        pi.X = piStart(2);   % x stage
        pi.Y = piStart(3); % y stage
        pi.Z = piStart(4);   % z stage
    otherwise
        error 'Unknown configuration!\n';
end
        
end
