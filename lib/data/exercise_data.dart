
import 'package:burnout/models/exercise_model.dart';

class SampleData {
  static List<ExerciseModel> get exercises => [
    // running
    // ExerciseModel(
    //   id: 'running',
    //   name: 'Running',
    //   muscleGroup: 'Cardio',
    //   category: 'Cardio',
    //   instructions: 'Run at a steady pace for a set distance or time, maintaining good form and breathing.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.4,
    //     'Hamstrings': 0.3,
    //     'Calves': 0.3,
    //   },
    //   type: 'Duration',
    //   weightedSupport: false
    // ),
    // // tricep rope pushdown
    // ExerciseModel(
    //   id: 'tricep_rope_pushdown',
    //   name: 'Tricep Rope Pushdown',
    //   muscleGroup: 'Arms',
    //   category: 'Cable Machine',
    //   instructions: 'Stand facing a cable machine with a rope attachment. Grip the rope with both hands, elbows close to your body, and push the rope down until your arms are fully extended.',
    //   targetedMuscles: {
    //     'Triceps': 0.7,
    //     'Forearms': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // bench press
    // ExerciseModel(
    //   id: 'bench_press',
    //   name: 'Bench Press',
    //   muscleGroup: 'Chest',
    //   category: 'Free Weights',
    //   instructions: 'Lie on a bench with a barbell at chest level. Grip the barbell and press it upwards until your arms are fully extended, then lower it back down to your chest.',
    //   targetedMuscles: {
    //     'Pectoralis Major': 0.5,
    //     'Triceps': 0.3,
    //     'Front Deltoids': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell bench press
    // ExerciseModel(
    //   id: 'dumbbell_bench_press',
    //   name: 'Dumbbell Bench Press',
    //   muscleGroup: 'Chest',
    //   category: 'Free Weights',
    //   instructions: 'Lie on a bench with a dumbbell in each hand at chest level. Grip the dumbbells and press them upwards until your arms are fully extended, then lower them back down to your chest.',
    //   targetedMuscles: {
    //     'Pectoralis Major': 0.5,
    //     'Triceps': 0.3,
    //     'Front Deltoids': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell lateral raise
    // ExerciseModel(
    //   id: 'dumbbell_lateral_raise',
    //   name: 'Dumbbell Lateral Raise',
    //   muscleGroup: 'Shoulders',
    //   category: 'Free Weights',
    //   instructions: 'Stand with a dumbbell in each hand at your sides. Raise the dumbbells out to the sides until your arms are parallel to the ground, then lower them back down.',
    //   targetedMuscles: {
    //     'Lateral Deltoids': 0.7,
    //     'Trapezius': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // lat pulldown
    // ExerciseModel(
    //   id: 'lat_pulldown',
    //   name: 'Lat Pulldown',
    //   muscleGroup: 'Back',
    //   category: 'Cable Machine',
    //   instructions: 'Sit at a lat pulldown machine, grip the bar with an overhand grip, pull the bar down towards your chest while keeping your back straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.6,
    //     'Biceps': 0.2,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // cable bicep curl
    // ExerciseModel(
    //   id: 'cable_bicep_curl',
    //   name: 'Cable Bicep Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Cable Machine',
    //   instructions: 'Stand facing a cable machine with a straight bar attachment. Grip the bar with both hands, palms facing up, and curl the bar towards your shoulders while keeping your elbows close to your body.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // iso-lateral chest press
    // ExerciseModel(
    //   id: 'iso_lateral_chest_press',
    //   name: 'Iso-Lateral Chest Press',
    //   muscleGroup: 'Chest',
    //   category: 'Plate-Loaded Machine',
    //   instructions: 'Sit on an iso-lateral chest press machine, grip the handles, and press them forward while keeping your elbows slightly bent, then return to the starting position.',
    //   targetedMuscles: {
    //     'Pectoralis Major': 0.6,
    //     'Anterior Deltoids': 0.2,
    //     'Triceps': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // iso-lateral shoulder press
    // ExerciseModel(
    //   id: 'iso_lateral_shoulder_press',
    //   name: 'Iso-Lateral Shoulder Press',
    //   muscleGroup: 'Shoulders',
    //   category: 'Plate-Loaded Machine',
    //   instructions: 'Sit on an iso-lateral shoulder press machine, grip the handles, and press them overhead while keeping your elbows slightly bent, then return to the starting position.',
    //   targetedMuscles: {
    //     'Deltoids': 0.6,
    //     'Triceps': 0.3,
    //     'Upper Chest': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine chest fly
    // ExerciseModel(
    //   id: 'machine_chest_fly',
    //   name: 'Machine Chest Fly',
    //   muscleGroup: 'Chest',
    //   category: 'Cable Machine',
    //   instructions: 'Sit on a chest fly machine, grip the handles, and bring them together in front of your chest while keeping your elbows slightly bent, then return to the starting position.',
    //   targetedMuscles: {
    //     'Pectoralis Major': 0.6,
    //     'Anterior Deltoids': 0.2,
    //     'Triceps': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // straight arm pulldown
    // ExerciseModel(
    //   id: 'straight_arm_pulldown',
    //   name: 'Straight Arm Pulldown',
    //   muscleGroup: 'Back',
    //   category: 'Cable Machine',
    //   instructions: 'Stand facing a cable machine with a straight bar attachment at shoulder height. Grip the bar with both hands, arms straight, and pull the bar down towards your thighs while keeping your arms straight.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.6,
    //     'Trapezius': 0.2,
    //     'Deltoids': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // wrist curl
    // ExerciseModel(
    //   id: 'wrist_curl',
    //   name: 'Wrist Curl',
    //   muscleGroup: 'Forearms',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with your forearms resting on your thighs, holding a dumbbell in each hand. Curl the dumbbells upwards by flexing your wrists, then lower them back down.',
    //   targetedMuscles: {
    //     'Flexor Muscles of Forearm': 0.8,
    //     'Extensor Muscles of Forearm': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // assisted pull-up
    // ExerciseModel(
    //   id: 'assisted_pull_up',
    //   name: 'Assisted Pull Up',
    //   muscleGroup: 'Back',
    //   category: 'Assisted Machine',
    //   instructions: 'Use an assisted pull-up machine, grip the handles, and pull your body up while the machine assists you by counterbalancing your weight.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.5,
    //     'Biceps': 0.3,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // pull-up
    // ExerciseModel(
    //   id: 'pull_up',
    //   name: 'Pull Up',
    //   muscleGroup: 'Back',
    //   category: 'Bodyweight',
    //   instructions: 'Hang from a pull-up bar with an overhand grip, pull your body up until your chin is above the bar, then lower yourself back down.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.5,
    //     'Biceps': 0.3,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Bodyweight Reps',
    //   weightedSupport: true
    // ),
    // // negative pullups
    // ExerciseModel(
    //   id: 'negative_pullups',
    //   name: 'Negative Pull Ups',
    //   muscleGroup: 'Back',
    //   category: 'Bodyweight',
    //   instructions: 'Jump or step up to the top position of a pull-up, then slowly lower yourself down to a dead hang position.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.5,
    //     'Biceps': 0.3,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Bodyweight Reps',
    //   weightedSupport: false
    // ),
    // // reverse wrist curl
    // ExerciseModel(
    //   id: 'reverse_wrist_curl',
    //   name: 'Reverse Wrist Curl',
    //   muscleGroup: 'Forearms',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with your forearms resting on your thighs, holding a dumbbell in each hand with palms facing down. Curl the dumbbells upwards by extending your wrists, then lower them back down.',
    //   targetedMuscles: {
    //     'Extensor Muscles of Forearm': 0.8,
    //     'Flexor Muscles of Forearm': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // seated dumbbell lateral raise
    // ExerciseModel(
    //   id: 'seated_dumbbell_lateral_raise',
    //   name: 'Seated Dumbbell Lateral Raise',
    //   muscleGroup: 'Shoulders',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with a dumbbell in each hand at your sides. Raise the dumbbells out to the sides until your arms are parallel to the ground, then lower them back down.',
    //   targetedMuscles: {
    //     'Lateral Deltoids': 0.7,
    //     'Trapezius': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // seated dumbbell shoulder press
    // ExerciseModel(
    //   id: 'seated_dumbbell_shoulder_press',
    //   name: 'Seated Dumbbell Shoulder Press',
    //   muscleGroup: 'Shoulders',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with a dumbbell in each hand at shoulder height. Press the dumbbells overhead until your arms are fully extended, then lower them back to shoulder height.',
    //   targetedMuscles: {
    //     'Deltoids': 0.5,
    //     'Triceps': 0.3,
    //     'Upper Chest': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // seated leg curl
    // ExerciseModel(
    //   id: 'seated_leg_curl',
    //   name: 'Seated Leg Curl',
    //   muscleGroup: 'Legs',
    //   category: 'Machine',
    //   instructions: 'Sit on a leg curl machine with your legs straight. Place your ankles under the padded lever, curl your legs down towards your glutes, then return to the starting position.',
    //   targetedMuscles: {
    //     'Hamstrings': 0.7,
    //     'Calves': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // seated leg extension
    // ExerciseModel(
    //   id: 'seated_leg_extension',
    //   name: 'Seated Leg Extension',
    //   muscleGroup: 'Legs',
    //   category: 'Machine',
    //   instructions: 'Sit on a leg extension machine with your legs straight. Place your ankles under the padded lever, extend your legs outwards until they are fully straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.8,
    //     'Hip Flexors': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // cable lateral raise
    // ExerciseModel(
    //   id: 'cable_lateral_raise',
    //   name: 'Cable Lateral Raise',
    //   muscleGroup: 'Shoulders',
    //   category: 'Cable Machine',
    //   instructions: 'Stand next to a cable machine with the pulley set at the lowest position. Grip the handle with one hand, raise it out to the side until your arm is parallel to the ground, then lower it back down.',
    //   targetedMuscles: {
    //     'Lateral Deltoids': 0.7,
    //     'Trapezius': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dead hang
    // ExerciseModel(
    //   id: 'dead_hang',
    //   name: 'Dead Hang',
    //   muscleGroup: 'Back',
    //   category: 'Bodyweight',
    //   instructions: 'Hang from a pull-up bar with an overhand grip, arms fully extended, and hold the position for as long as possible.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.4,
    //     'Forearms': 0.3,
    //     'Shoulders': 0.3,
    //   },
    //   type: 'Bodyweight Hold',
    //   weightedSupport: false
    // ),
    // // incline bench press
    // ExerciseModel(
    //   id: 'incline_bench_press',
    //   name: 'Incline Bench Press',
    //   muscleGroup: 'Chest',
    //   category: 'Free Weights',
    //   instructions: 'Lie on an incline bench with a barbell at chest level. Grip the barbell and press it upwards until your arms are fully extended, then lower it back down to your chest.',
    //   targetedMuscles: {
    //     'Upper Pectoralis Major': 0.5,
    //     'Triceps': 0.3,
    //     'Front Deltoids': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // iso-lateral low row
    // ExerciseModel(
    //   id: 'iso_lateral_low_row',
    //   name: 'Iso-Lateral Low Row',
    //   muscleGroup: 'Back',
    //   category: 'Plate-Loaded Machine',
    //   instructions: 'Sit on an iso-lateral low row machine, grip the handles, and pull them towards your torso while keeping your elbows close to your body, then return to the starting position.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.6,
    //     'Biceps': 0.2,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine reverse fly
    // ExerciseModel(
    //   id: 'machine_reverse_fly',
    //   name: 'Machine Reverse Fly',
    //   muscleGroup: 'Shoulders',
    //   category: 'Cable Machine',
    //   instructions: 'Sit on a reverse fly machine, grip the handles, and pull them out to the sides while keeping your elbows slightly bent, then return to the starting position.',
    //   targetedMuscles: {
    //     'Rear Deltoids': 0.6,
    //     'Trapezius': 0.2,
    //     'Rhomboids': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // preacher curl
    // ExerciseModel(
    //   id: 'preacher_curl',
    //   name: 'Preacher Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Free Weights',
    //   instructions: 'Sit at a preacher curl bench with a barbell or dumbbells. Rest your arms on the bench and curl the weight towards your shoulders, then lower it back down.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // squat
    // ExerciseModel(
    //   id: 'squat',
    //   name: 'Squat',
    //   muscleGroup: 'Legs',
    //   category: 'Free Weights',
    //   instructions: 'Stand with feet shoulder-width apart, lower your body by bending your knees and hips, then return to standing position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.4,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // incline dumbbell bench press
    // ExerciseModel(
    //   id: 'incline_dumbbell_bench_press',
    //   name: 'Incline Dumbbell Bench Press',
    //   muscleGroup: 'Chest',
    //   category: 'Free Weights',
    //   instructions: 'Lie on an incline bench with a dumbbell in each hand at chest level. Grip the dumbbells and press them upwards until your arms are fully extended, then lower them back down to your chest.',
    //   targetedMuscles: {
    //     'Upper Pectoralis Major': 0.5,
    //     'Triceps': 0.3,
    //     'Front Deltoids': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine row
    // ExerciseModel(
    //   id: 'machine_row',
    //   name: 'Machine Row',
    //   muscleGroup: 'Back',
    //   category: 'Machine',
    //   instructions: 'Sit at a rowing machine, grip the handles, and pull them towards your torso while keeping your elbows close to your body, then return to the starting position.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.6,
    //     'Biceps': 0.2,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // reverse hyperextension
    // ExerciseModel(
    //   id: 'reverse_hyperextension',
    //   name: 'Reverse Hyperextension',
    //   muscleGroup: 'Lower Back',
    //   category: 'Machine',
    //   instructions: 'Lie face down on a reverse hyperextension machine, grip the handles, and lift your legs upwards while keeping your hips pressed against the pad, then lower them back down.',
    //   targetedMuscles: {
    //     'Lower Back': 0.6,
    //     'Glutes': 0.4,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // seated calf raise
    // ExerciseModel(
    //   id: 'seated_calf_raise',
    //   name: 'Seated Calf Raise',
    //   muscleGroup: 'Calves',
    //   category: 'Machine',
    //   instructions: 'Sit on a calf raise machine with your feet on the platform and your knees under the padded lever. Raise your heels by extending your ankles, then lower them back down.',
    //   targetedMuscles: {
    //     'Gastrocnemius': 0.6,
    //     'Soleus': 0.4,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // assissted dip
    // ExerciseModel(
    //   id: 'assisted_dip',
    //   name: 'Assisted Dip',
    //   muscleGroup: 'Arms',
    //   category: 'Assisted Machine',
    //   instructions: 'Use an assisted dip machine, grip the handles, and lower your body by bending your elbows, then push yourself back up to the starting position while the machine assists you by counterbalancing your weight.',
    //   targetedMuscles: {
    //     'Triceps': 0.6,
    //     'Chest': 0.3,
    //     'Shoulders': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // barbell curl
    // ExerciseModel(
    //   id: 'barbell_curl',
    //   name: 'Barbell Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Free Weights',
    //   instructions: 'Stand with a barbell in both hands, arms fully extended. Curl the barbell towards your shoulders while keeping your elbows close to your body, then lower it back down.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // bayesian curl
    // ExerciseModel(
    //   id: 'bayesian_curl',
    //   name: 'Bayesian Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Free Weights',
    //   instructions: 'Stand with a cable machine set at the lowest position. Grip the handle with one hand, lean back slightly, and curl the handle towards your shoulder while keeping your elbow stationary.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // cable overhead tricep extension
    // ExerciseModel(
    //   id: 'cable_overhead_tricep_extension',
    //   name: 'Cable Overhead Tricep Extension',
    //   muscleGroup: 'Arms',
    //   category: 'Cable Machine',
    //   instructions: 'Stand facing away from a cable machine with the pulley set at the highest position. Grip the rope attachment with both hands, extend your arms overhead, then lower the rope behind your head by bending your elbows.',
    //   targetedMuscles: {
    //     'Triceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell row
    // ExerciseModel(
    //   id: 'dumbbell_row',
    //   name: 'Dumbbell Row',
    //   muscleGroup: 'Back',
    //   category: 'Free Weights',
    //   instructions: 'Stand with a dumbbell in one hand, bend forward at the hips while keeping your back straight, and pull the dumbbell towards your torso while keeping your elbow close to your body.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.5,
    //     'Biceps': 0.3,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // incline dumbbell curl
    // ExerciseModel(
    //   id: 'incline_dumbbell_curl',
    //   name: 'Incline Dumbbell Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Free Weights',
    //   instructions: 'Sit on an incline bench with a dumbbell in each hand, arms fully extended. Curl the dumbbells towards your shoulders while keeping your elbows stationary, then lower them back down.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // sled leg press
    // ExerciseModel(
    //   id: 'sled_leg_press',
    //   name: 'Sled Leg Press',
    //   muscleGroup: 'Legs',
    //   category: 'Sled Machine',
    //   instructions: 'Sit on a sled leg press machine with your feet on the platform. Push the platform away by extending your legs, then return to the starting position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.5,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // one arm dumbbell preacher curl
    // ExerciseModel(
    //   id: 'one_arm_dumbbell_preacher_curl',
    //   name: 'One Arm Dumbbell Preacher Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Free Weights',
    //   instructions: 'Sit at a preacher curl bench with a dumbbell in one hand. Rest your arm on the bench and curl the dumbbell towards your shoulder, then lower it back down.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // sled press calf raise
    // ExerciseModel(
    //   id: 'sled_press_calf_raise',
    //   name: 'Sled Press Calf Raise',
    //   muscleGroup: 'Calves',
    //   category: 'Sled Machine',
    //   instructions: 'Sit on a sled machine with your feet on the platform. Raise your heels by extending your ankles, then lower them back down.',
    //   targetedMuscles: {
    //     'Gastrocnemius': 0.6,
    //     'Soleus': 0.4,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // front squat
    // ExerciseModel(
    //   id: 'front_squat',
    //   name: 'Front Squat',
    //   muscleGroup: 'Legs',
    //   category: 'Free Weights',
    //   instructions: 'Stand with feet shoulder-width apart, hold a barbell across the front of your shoulders, lower your body by bending your knees and hips, then return to standing position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.5,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // barbell hip thrust
    // ExerciseModel(
    //   id: 'barbell_hip_thrust',
    //   name: 'Barbell Hip Thrust',
    //   muscleGroup: 'Glutes',
    //   category: 'Free Weights',
    //   instructions: 'Sit on the ground with your upper back against a bench, roll a barbell over your hips, and thrust your hips upwards until your body is in a straight line from shoulders to knees.',
    //   targetedMuscles: {
    //     'Glutes': 0.6,
    //     'Hamstrings': 0.3,
    //     'Lower Back': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // bent-over row
    // ExerciseModel(
    //   id: 'bent_over_row',
    //   name: 'Bent-Over Row',
    //   muscleGroup: 'Back',
    //   category: 'Free Weights',
    //   instructions: 'Stand with feet shoulder-width apart, bend forward at the hips while keeping your back straight, and pull a barbell or dumbbells towards your torso while keeping your elbows close to your body.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.5,
    //     'Biceps': 0.3,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // cable tricep pushdown
    // ExerciseModel(
    //   id: 'cable_tricep_pushdown',
    //   name: 'Cable Tricep Pushdown',
    //   muscleGroup: 'Arms',
    //   category: 'Cable Machine',
    //   instructions: 'Stand facing a cable machine with a straight bar attachment. Grip the bar with both hands, elbows close to your body, and push the bar down until your arms are fully extended.',
    //   targetedMuscles: {
    //     'Triceps': 0.7,
    //     'Forearms': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine seated crunch
    // ExerciseModel(
    //   id: 'machine_seated_crunch',
    //   name: 'Machine Seated Crunch',
    //   muscleGroup: 'Core',
    //   category: 'Machine',
    //   instructions: 'Sit on a seated crunch machine, grip the handles, and crunch your torso down towards your thighs while keeping your back straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Rectus Abdominis': 0.7,
    //     'Obliques': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell curl
    // ExerciseModel(
    //   id: 'dumbbell_curl',
    //   name: 'Dumbbell Curl',
    //   muscleGroup: 'Arms',
    //   category: 'Free Weights',
    //   instructions: 'Stand with a dumbbell in each hand, arms fully extended. Curl the dumbbells towards your shoulders while keeping your elbows close to your body, then lower them back down.',
    //   targetedMuscles: {
    //     'Biceps': 0.8,
    //     'Forearms': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // deadlift
    // ExerciseModel(
    //   id: 'deadlift',
    //   name: 'Deadlift',
    //   muscleGroup: 'Back',
    //   category: 'Free Weights',
    //   instructions: 'Stand with feet hip-width apart, grip the barbell on the floor, lift it by extending your hips and knees until you are standing upright.',
    //   targetedMuscles: {
    //     'Hamstrings': 0.4,
    //     'Glutes': 0.3,
    //     'Lower Back': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // romanian deadlift
    // ExerciseModel(
    //   id: 'romanian_deadlift',
    //   name: 'Romanian Deadlift',
    //   muscleGroup: 'Legs',
    //   category: 'Free Weights',
    //   instructions: 'Stand with feet hip-width apart, hold a barbell in front of your thighs, bend forward at the hips while keeping your back straight, and lower the barbell towards the ground, then return to standing position.',
    //   targetedMuscles: {
    //     'Hamstrings': 0.5,
    //     'Glutes': 0.3,
    //     'Lower Back': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // bulgarian split squat
    // ExerciseModel(
    //   id: 'bulgarian_split_squat',
    //   name: 'Bulgarian Split Squat',
    //   muscleGroup: 'Legs',
    //   category: 'Free Weights',
    //   instructions: 'Stand a few feet in front of a bench, place one foot on the bench behind you, lower your body by bending your front knee until your thigh is parallel to the ground, then return to standing position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.4,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // cable face pull
    // ExerciseModel(
    //   id: 'cable_face_pull',
    //   name: 'Cable Face Pull',
    //   muscleGroup: 'Shoulders',
    //   category: 'Cable Machine',
    //   instructions: 'Stand facing a cable machine with the pulley set at upper chest height. Grip the rope attachment with both hands, pull the rope towards your face while keeping your elbows high, then return to the starting position.',
    //   targetedMuscles: {
    //     'Rear Deltoids': 0.6,
    //     'Trapezius': 0.3,
    //     'Rhomboids': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine hip adduction
    // ExerciseModel(
    //   id: 'machine_hip_adduction',
    //   name: 'Machine Hip Adduction',
    //   muscleGroup: 'Legs',
    //   category: 'Machine',
    //   instructions: 'Sit on a hip adduction machine, place your legs against the padded levers, and squeeze your legs together while keeping your back straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Adductors': 0.7,
    //     'Quadriceps': 0.2,
    //     'Hamstrings': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine hip abduction
    // ExerciseModel(
    //   id: 'machine_hip_abduction',
    //   name: 'Machine Hip Abduction',
    //   muscleGroup: 'Legs',
    //   category: 'Machine',
    //   instructions: 'Sit on a hip abduction machine, place your legs against the padded levers, and push your legs apart while keeping your back straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Gluteus Medius': 0.6,
    //     'Gluteus Maximus': 0.3,
    //     'Quadriceps': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine glute kickback
    // ExerciseModel(
    //   id: 'machine_glute_kickback',
    //   name: 'Machine Glute Kickback',
    //   muscleGroup: 'Glutes',
    //   category: 'Machine',
    //   instructions: 'Stand facing a glute kickback machine, place one foot on the padded lever, and extend your leg back while keeping your back straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Glutes': 0.7,
    //     'Hamstrings': 0.2,
    //     'Lower Back': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine chest press
    // ExerciseModel(
    //   id: 'machine_chest_press',
    //   name: 'Machine Chest Press',
    //   muscleGroup: 'Chest',
    //   category: 'Machine',
    //   instructions: 'Sit on a chest press machine, grip the handles, and press them forward while keeping your elbows slightly bent, then return to the starting position.',
    //   targetedMuscles: {
    //     'Pectoralis Major': 0.6,
    //     'Anterior Deltoids': 0.2,
    //     'Triceps': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine shoulder press
    // ExerciseModel(
    //   id: 'machine_shoulder_press',
    //   name: 'Machine Shoulder Press',
    //   muscleGroup: 'Shoulders',
    //   category: 'Machine',
    //   instructions: 'Sit on a shoulder press machine, grip the handles, and press them overhead while keeping your elbows slightly bent, then return to the starting position.',
    //   targetedMuscles: {
    //     'Deltoids': 0.6,
    //     'Triceps': 0.3,
    //     'Upper Chest': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // machine leg press
    // ExerciseModel(
    //   id: 'machine_leg_press',
    //   name: 'Machine Leg Press',
    //   muscleGroup: 'Legs',
    //   category: 'Machine',
    //   instructions: 'Sit on a leg press machine with your feet on the platform. Push the platform away by extending your legs, then return to the starting position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.5,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell wrist curl
    // ExerciseModel(
    //   id: 'dumbbell_wrist_curl',
    //   name: 'Dumbbell Wrist Curl',
    //   muscleGroup: 'Forearms',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with your forearms resting on your thighs, holding a dumbbell in each hand. Curl the dumbbells upwards by flexing your wrists, then lower them back down.',
    //   targetedMuscles: {
    //     'Flexor Muscles of Forearm': 0.8,
    //     'Extensor Muscles of Forearm': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell reverse wrist curl
    // ExerciseModel(
    //   id: 'dumbbell_reverse_wrist_curl',
    //   name: 'Dumbbell Reverse Wrist Curl',
    //   muscleGroup: 'Forearms',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with your forearms resting on your thighs, holding a dumbbell in each hand with palms facing down. Curl the dumbbells upwards by extending your wrists, then lower them back down.',
    //   targetedMuscles: {
    //     'Extensor Muscles of Forearm': 0.8,
    //     'Flexor Muscles of Forearm': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // glute hyperextension
    // ExerciseModel(
    //   id: 'glute_hyperextension',
    //   name: 'Glute Hyperextension',
    //   muscleGroup: 'Glutes',
    //   category: 'Machine',
    //   instructions: 'Lie face down on a hyperextension bench with your hips at the edge. Lower your upper body towards the ground, then raise it back up by contracting your glutes.',
    //   targetedMuscles: {
    //     'Glutes': 0.6,
    //     'Hamstrings': 0.3,
    //     'Lower Back': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // split squat
    // ExerciseModel(
    //   id: 'split_squat',
    //   name: 'Split Squat',
    //   muscleGroup: 'Legs',
    //   category: 'Free Weights',
    //   instructions: 'Stand with one foot forward and the other foot back, lower your body by bending your front knee until your thigh is parallel to the ground, then return to standing position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.4,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // tibialis raise
    // ExerciseModel(
    //   id: 'tibialis_raise',
    //   name: 'Tibialis Raise',
    //   muscleGroup: 'Lower Legs',
    //   category: 'Free Weights',
    //   instructions: 'Sit on a bench with your feet flat on the ground. Lift your toes upwards while keeping your heels on the ground, then lower them back down.',
    //   targetedMuscles: {
    //     'Tibialis Anterior': 0.8,
    //     'Calves': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // cable woodchopper
    // ExerciseModel(
    //   id: 'cable_woodchopper',
    //   name: 'Cable Woodchopper',
    //   muscleGroup: 'Core',
    //   category: 'Cable Machine',
    //   instructions: 'Stand next to a cable machine with the pulley set at the highest position. Grip the handle with both hands, pull it down and across your body while rotating your torso, then return to the starting position.',
    //   targetedMuscles: {
    //     'Obliques': 0.6,
    //     'Rectus Abdominis': 0.3,
    //     'Shoulders': 0.1,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // chest supported t-bar row
    // ExerciseModel(
    //   id: 'chest_supported_t_bar_row',
    //   name: 'Chest Supported T-Bar Row',
    //   muscleGroup: 'Back',
    //   category: 'Free Weights',
    //   instructions: 'Lie face down on a chest-supported row bench, grip the T-bar handle, and pull it towards your torso while keeping your elbows close to your body, then return to the starting position.',
    //   targetedMuscles: {
    //     'Latissimus Dorsi': 0.6,
    //     'Biceps': 0.2,
    //     'Trapezius': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // shoulder press
    // ExerciseModel(
    //   id: 'shoulder_press',
    //   name: 'Shoulder Press',
    //   muscleGroup: 'Shoulders',
    //   category: 'Free Weights',
    //   instructions: 'Sit or stand with a barbell or dumbbells at shoulder height, press them overhead until your arms are fully extended, then lower them back to shoulder height.',
    //   targetedMuscles: {
    //     'Deltoids': 0.5,
    //     'Triceps': 0.3,
    //     'Upper Chest': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // dumbbell side bend
    // ExerciseModel(
    //   id: 'dumbbell_side_bend',
    //   name: 'Dumbbell Side Bend',
    //   muscleGroup: 'Core',
    //   category: 'Free Weights',
    //   instructions: 'Stand with a dumbbell in one hand, feet shoulder-width apart. Lean to the side, bringing the dumbbell down towards your knee, then return to the starting position.',
    //   targetedMuscles: {
    //     'Obliques': 0.7,
    //     'Rectus Abdominis': 0.3,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // horizontal leg press
    // ExerciseModel(
    //   id: 'horizontal_leg_press',
    //   name: 'Horizontal Leg Press',
    //   muscleGroup: 'Legs',
    //   category: 'Machine',
    //   instructions: 'Sit on a horizontal leg press machine with your feet on the platform. Push the platform away by extending your legs, then return to the starting position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.5,
    //     'Hamstrings': 0.3,
    //     'Glutes': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // palloff press
    // ExerciseModel(
    //   id: 'palloff_press',
    //   name: 'Palloff Press',
    //   muscleGroup: 'Core',
    //   category: 'Cable Machine',
    //   instructions: 'Stand next to a cable machine with the pulley set at chest height. Grip the handle with both hands, press it away from your chest while keeping your core engaged, then return to the starting position.',
    //   targetedMuscles: {
    //     'Rectus Abdominis': 0.6,
    //     'Obliques': 0.4,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),
    // // iso-lateral leg extension
    // ExerciseModel(
    //   id: 'iso_lateral_leg_extension',
    //   name: 'Iso-Lateral Leg Extension',
    //   muscleGroup: 'Legs',
    //   category: 'Plate-Loaded Machine',
    //   instructions: 'Sit on an iso-lateral leg extension machine, grip the handles, and extend one leg at a time while keeping your back straight, then return to the starting position.',
    //   targetedMuscles: {
    //     'Quadriceps': 0.8,
    //     'Hip Flexors': 0.2,
    //   },
    //   type: 'Weighted Reps',
    //   weightedSupport: true
    // ),

  ];
}