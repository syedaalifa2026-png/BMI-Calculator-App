// lib/services/ai_chat_service.dart

class AIChatService {
  static List<Map<String, String>> _getHealthResponses(String input, String category, double bmi) {
    final lowerInput = input.toLowerCase();

    // BMI related queries
    if (lowerInput.contains('bmi') || lowerInput.contains('weight')) {
      return [
        {
          'role': 'assistant',
          'content':
              'Your current BMI is ${bmi.toStringAsFixed(1)}, which falls in the **$category** range.\n\n'
              '📊 **BMI Scale:**\n'
              '• < 18.5 → Underweight\n'
              '• 18.5–24.9 → Normal ✅\n'
              '• 25–29.9 → Overweight\n'
              '• ≥ 30 → Obese\n\n'
              'Would you like specific advice for your current category?',
        }
      ];
    }

    if (lowerInput.contains('diet') || lowerInput.contains('food') || lowerInput.contains('eat')) {
      return _getDietResponse(category);
    }

    if (lowerInput.contains('exercise') || lowerInput.contains('workout') || lowerInput.contains('gym')) {
      return _getExerciseResponse(category);
    }

    if (lowerInput.contains('sleep')) {
      return [
        {
          'role': 'assistant',
          'content':
              '😴 **Sleep & Health Connection:**\n\n'
              'Adequate sleep is crucial for weight management and overall health.\n\n'
              '**Recommendations:**\n'
              '• Adults need 7–9 hours per night\n'
              '• Poor sleep increases hunger hormones (ghrelin)\n'
              '• Sleep deprivation can lead to weight gain\n'
              '• Consistent sleep schedule improves metabolism\n\n'
              '💡 **Tips for better sleep:**\n'
              '• Avoid screens 1 hour before bed\n'
              '• Keep room cool and dark\n'
              '• Avoid caffeine after 2 PM',
        }
      ];
    }

    if (lowerInput.contains('water') || lowerInput.contains('hydrat')) {
      return [
        {
          'role': 'assistant',
          'content':
              '💧 **Hydration Tips:**\n\n'
              'Proper hydration is essential for metabolism and overall health.\n\n'
              '**Daily Water Goals:**\n'
              '• Men: ~3.7 liters (15 cups)\n'
              '• Women: ~2.7 liters (11 cups)\n\n'
              '**Benefits of staying hydrated:**\n'
              '• Boosts metabolism by 24-30%\n'
              '• Reduces appetite and calorie intake\n'
              '• Improves exercise performance\n'
              '• Flushes toxins and aids digestion\n\n'
              '💡 Drink a glass of water before each meal!',
        }
      ];
    }

    if (lowerInput.contains('stress') || lowerInput.contains('mental')) {
      return [
        {
          'role': 'assistant',
          'content':
              '🧠 **Mental Health & BMI:**\n\n'
              'Stress and mental health significantly impact body weight.\n\n'
              '**Stress Effects:**\n'
              '• Cortisol increases appetite and fat storage\n'
              '• Emotional eating can lead to weight gain\n'
              '• Poor mental health affects exercise motivation\n\n'
              '**Stress Management Strategies:**\n'
              '• Practice mindfulness or meditation (10 min/day)\n'
              '• Regular physical exercise reduces cortisol\n'
              '• Deep breathing exercises\n'
              '• Social connection and support\n\n'
              'Remember: your mental health is just as important as physical health! 💚',
        }
      ];
    }

    if (lowerInput.contains('calori') || lowerInput.contains('calorie')) {
      return _getCalorieResponse(category, bmi);
    }

    // Greeting
    if (lowerInput.contains('hello') || lowerInput.contains('hi') || 
        lowerInput.contains('hey') || lowerInput.contains('helo')) {
      return [
        {
          'role': 'assistant',
          'content':
              '👋 **Hello! I\'m VixoAI, your personal health assistant!**\n\n'
              'I can help you with:\n\n'
              '🏃 **Exercise recommendations**\n'
              '🥗 **Diet and nutrition advice**\n'
              '😴 **Sleep optimization**\n'
              '💧 **Hydration guidance**\n'
              '📊 **BMI interpretation**\n'
              '🧠 **Mental wellness tips**\n\n'
              'Your current BMI is **${bmi.toStringAsFixed(1)}** ($category).\n'
              'What would you like to know today?',
        }
      ];
    }

    // Default response
    return [
      {
        'role': 'assistant',
        'content':
            '🤔 I can help you with health topics related to your BMI.\n\n'
            'Try asking me about:\n'
            '• **Diet & nutrition** tips\n'
            '• **Exercise** recommendations\n'
            '• **Sleep** optimization\n'
            '• **Hydration** advice\n'
            '• **Stress** management\n'
            '• **Calorie** calculations\n\n'
            'Your current BMI is **${bmi.toStringAsFixed(1)}** ($category). How can I help?',
      }
    ];
  }

  static List<Map<String, String>> _getDietResponse(String category) {
    String advice = '';
    switch (category) {
      case 'Underweight':
        advice =
            '🥑 **Diet for Weight Gain:**\n\n'
            '**High-calorie nutritious foods:**\n'
            '• Nuts, seeds, and nut butters\n'
            '• Avocados and olive oil\n'
            '• Whole milk and dairy products\n'
            '• Whole grains (brown rice, quinoa)\n'
            '• Lean proteins (chicken, eggs, legumes)\n\n'
            '**Tips:**\n'
            '• Eat 5-6 meals per day\n'
            '• Add protein shakes between meals\n'
            '• Don\'t skip breakfast\n'
            '• Aim for 300-500 extra calories/day';
        break;
      case 'Normal':
        advice =
            '✅ **Balanced Diet to Maintain Weight:**\n\n'
            '**Daily plate composition:**\n'
            '• 50% fruits and vegetables\n'
            '• 25% whole grains\n'
            '• 25% lean proteins\n\n'
            '**Focus on:**\n'
            '• Mediterranean-style eating\n'
            '• Whole, minimally processed foods\n'
            '• Adequate fiber (25-30g/day)\n'
            '• Healthy fats (omega-3 rich foods)';
        break;
      default:
        advice =
            '🥦 **Diet for Weight Loss:**\n\n'
            '**Create a caloric deficit:**\n'
            '• Reduce intake by 300-500 cal/day\n'
            '• Focus on high-volume, low-calorie foods\n\n'
            '**Best food choices:**\n'
            '• Leafy greens and non-starchy vegetables\n'
            '• Lean proteins (keeps you full longer)\n'
            '• Legumes and beans (fiber-rich)\n'
            '• Berries and low-sugar fruits\n\n'
            '**Avoid:**\n'
            '• Processed foods and sugar\n'
            '• Liquid calories (soda, juice)\n'
            '• Large portions of refined carbs';
    }

    return [{'role': 'assistant', 'content': advice}];
  }

  static List<Map<String, String>> _getExerciseResponse(String category) {
    String advice = '';
    switch (category) {
      case 'Underweight':
        advice =
            '💪 **Exercise for Healthy Weight Gain:**\n\n'
            '**Focus on Strength Training:**\n'
            '• Resistance training 3-4x per week\n'
            '• Compound lifts (squats, deadlifts, bench press)\n'
            '• Progressive overload principle\n\n'
            '**Weekly Plan:**\n'
            '• Mon: Upper body strength\n'
            '• Wed: Lower body strength\n'
            '• Fri: Full body compound\n'
            '• Limit excessive cardio (burns too many calories)\n\n'
            '⚠️ Rest days are just as important for muscle building!';
        break;
      case 'Normal':
        advice =
            '🏃 **Exercise to Maintain Health:**\n\n'
            '**Recommended weekly activity:**\n'
            '• 150+ min moderate cardio OR 75 min vigorous\n'
            '• Strength training 2x per week\n'
            '• Flexibility/stretching daily\n\n'
            '**Fun options:**\n'
            '• Running, cycling, swimming\n'
            '• Yoga or Pilates\n'
            '• Team sports\n'
            '• Dance or aerobics\n\n'
            '✨ Variety keeps you motivated and prevents plateaus!';
        break;
      default:
        advice =
            '🚶 **Exercise for Weight Loss:**\n\n'
            '**Start gradually:**\n'
            '• Begin with 20-30 min walks daily\n'
            '• Add low-impact cardio (swimming, cycling)\n'
            '• Gradually increase duration and intensity\n\n'
            '**Effective approaches:**\n'
            '• HIIT workouts (burn more in less time)\n'
            '• Strength training (boosts metabolism)\n'
            '• Aim for 200-300 min cardio/week\n\n'
            '💡 **NEAT matters!** Take stairs, park far away, stand more.';
    }

    return [{'role': 'assistant', 'content': advice}];
  }

  static List<Map<String, String>> _getCalorieResponse(String category, double bmi) {
    return [
      {
        'role': 'assistant',
        'content':
            '🔢 **Calorie Guide for $category BMI:**\n\n'
            'Your BMI: ${bmi.toStringAsFixed(1)}\n\n'
            '**Estimated Daily Calorie Needs:**\n'
            '• Sedentary: ~1,600–2,000 kcal\n'
            '• Lightly active: ~1,800–2,200 kcal\n'
            '• Moderately active: ~2,000–2,500 kcal\n'
            '• Very active: ~2,200–3,000 kcal\n\n'
            '**For $category:**\n'
            '${_getCalorieTip(category)}\n\n'
            '💡 Use the Mifflin-St Jeor equation for precise TDEE calculation.',
      }
    ];
  }

  static String _getCalorieTip(String category) {
    switch (category) {
      case 'Underweight': return '• Aim for +300–500 kcal above your TDEE\n• Focus on calorie-dense, nutritious foods';
      case 'Normal': return '• Eat at your TDEE to maintain weight\n• Quality of calories matters as much as quantity';
      case 'Overweight': return '• Target -300–500 kcal deficit below TDEE\n• Gradual loss of 0.5–1 kg/week is sustainable';
      case 'Obese': return '• Work with a doctor for safe caloric targets\n• -500–750 kcal deficit is generally recommended';
      default: return '• Consult a nutritionist for personalized advice';
    }
  }

  static Future<String> getAIResponse(String userMessage, String category, double bmi) async {
    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final responses = _getHealthResponses(userMessage, category, bmi);
    if (responses.isNotEmpty) {
      return responses.first['content'] ?? 'I\'m here to help with your health journey!';
    }
    return 'I\'m here to help with your health journey! Ask me about diet, exercise, sleep, or hydration.';
  }
}
