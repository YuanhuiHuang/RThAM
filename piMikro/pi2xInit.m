function piStages = pi2xInit(configStages)

if nargin < 1
    configStages = 'RSOM';
end

configStages = upper(configStages);
piStages     = pi2xStart(configStages);
pi2xOpen(piStages);
pi2xServoOn(piStages, 1);