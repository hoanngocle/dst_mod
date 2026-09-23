local RANK = require("guild/hh_rank_defs").RANK

local EXAMS = {
    { id=1, rank=RANK.D, title="Bài Kiểm Tra: Cánh cửa đầu tiên", description="Nhiệm vụ: Đánh bại 5 Clockwork.", target=5, tracker="killed", group="clockworks", reward_credit=100, reward_items={{prefab="bluegem", amount=10}, {prefab="redgem", amount=10}} },
    { id=2, rank=RANK.C, title="Bài Kiểm Tra: Kẻ sống sót", description="Nhiệm vụ: Đánh bại 30 Hound.", target=30, tracker="killed", group="hounds", reward_credit=250, reward_items={{prefab="yellowgem", amount=10}, {prefab="orangegem", amount=10}} },
    { id=3, rank=RANK.B, title="Bài Kiểm Tra: Săn tinh anh", description="Nhiệm vụ: Đánh bại 4 Miniboss ngoài Dungeon.", target=4, tracker="killed", group="minibosses", reward_credit=400, reward_items={{prefab="opalpreciousgem", amount=10}, {prefab="hh_essence", amount=60}} },
    { id=4, rank=RANK.A, title="Bài Kiểm Tra: Hợp đồng boss", description="Nhiệm vụ: Đánh bại 4 Boss ngoài Dungeon.", target=4, tracker="killed", group="bosses", reward_credit=550, reward_items={{prefab="opalpreciousgem", amount=20}, {prefab="hh_essence", amount=80}} },
    { id=5, rank=RANK.S, title="Bài Kiểm Tra: Thống lĩnh chiến trường", description="Nhiệm vụ: Đánh bại 3 mục tiêu endgame ngoài dungeon.", target=3, tracker="killed", group="endgamebosses", reward_credit=800, reward_items={{prefab="purebrilliance", amount=40}, {prefab="horrorfuel", amount=40}} },
}

local BY_ID = {}
for _, exam in ipairs(EXAMS) do
    BY_ID[exam.id] = exam
end

return {
    list = EXAMS,
    by_id = BY_ID,
    Get = function(id)
        return BY_ID[tonumber(id)]
    end,
}
