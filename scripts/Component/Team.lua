local Team = {}

function Team.start(unit, defaultteam, defaultenemyteams)
    unit.team = unit.team or defaultteam
    unit.enemyteams = unit.enemyteams or defaultenemyteams
end

function Team.isEnemyOf(unit, other)
    return string.find(other.enemyteams or "", unit.team or "")
end

return Team