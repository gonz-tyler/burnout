package com.burnout.app.ui.quests

import com.burnout.app.R
import com.burnout.app.domain.service.QuestId
import com.burnout.app.domain.service.QuestProgress
import com.burnout.app.domain.service.QuestsService
import com.burnout.app.util.UiText
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter

/** UI model: progress from the domain plus the text and art to show for it. */
data class Quest(
    val id: QuestId,
    val title: UiText,
    val description: UiText,
    val requirement: UiText,
    val rewardAsset: String,
    val isCompleted: Boolean,
    val progress: Float,
)

fun List<QuestProgress>.toQuests(weeklyGoal: Int, unit: UnitSystem): List<Quest> = map { p ->
    when (p.id) {
        QuestId.WEEKLY_GOAL -> Quest(
            id = p.id,
            title = UiText.StringResource(R.string.q1_title),
            description = UiText.StringResource(R.string.q1_description),
            requirement = UiText.StringResource(R.string.q1_requirement, weeklyGoal),
            rewardAsset = "crown_reward.png",
            isCompleted = p.isCompleted,
            progress = p.progress,
        )
        QuestId.WEEKLY_VOLUME -> Quest(
            id = p.id,
            title = UiText.StringResource(R.string.q2_title),
            description = UiText.StringResource(R.string.q2_description),
            requirement = UiText.StringResource(
                R.string.q2_requirement,
                WeightConverter.displayWeight(QuestsService.WEEKLY_VOLUME_TARGET, unit),
                if (unit == UnitSystem.METRIC) "kg" else "lbs",
            ),
            rewardAsset = "weight_reward.png",
            isCompleted = p.isCompleted,
            progress = p.progress,
        )
        QuestId.EARLY_BIRD -> Quest(
            id = p.id,
            title = UiText.StringResource(R.string.q3_title),
            description = UiText.StringResource(R.string.q3_description),
            requirement = UiText.StringResource(R.string.q3_requirement),
            rewardAsset = "sun_reward.png",
            isCompleted = p.isCompleted,
            progress = p.progress,
        )
    }
}