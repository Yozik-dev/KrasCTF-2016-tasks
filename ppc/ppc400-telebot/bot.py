# -*- coding: utf-8 -*-
import os
import random
from datetime import datetime
import traceback
from PIL import Image
import re
from telegram.ext import Updater, CommandHandler, ConversationHandler, MessageHandler, Filters

from models import UserHits


STEP_SECOND_IMAGE = 1
STEP_FINISH = 2
TIME_TO_ANSWER = 2
FLAG = 'n0w_y0u_kn0w_m0re_ab0ut_telegram_b0ts'


def start(bot, update):
    try:
        blank, answer = generate_image()
        user_id = update.message.from_user.id

        user_hit = UserHits.select().where(UserHits.user_id == update.message.from_user.id)
        if user_hit.count() == 0:
            user_hit = UserHits(user_id=user_id)
        else:
            user_hit = user_hit.get()

        summ_a = random.randrange(100, 999)
        summ_b = random.randrange(100, 999)
        user_hit.user_name = update.message.from_user.name
        user_hit.key_1 = str(answer.values())
        user_hit.start_time_1 = datetime.now()
        user_hit.check_1 = summ_a + summ_b
        user_hit.save()

        print 'start with ' + user_hit.user_name
        text ='Be faster and tell me, what did you see here? Plus check summ = %d + %d ' \
              '[<n> quads, <n> circles, <n> triangles, <summ>]' % (summ_a, summ_b)
        print text

        filename = 'temp/' + str(random.random()) + '.png'
        blank.save(filename)
        bot.sendPhoto(update.message.chat_id, photo=open(filename, 'rb'))
        bot.sendMessage(update.message.chat_id,
                        text=text)
        os.remove(filename)

        return STEP_SECOND_IMAGE
    except Exception:
        print traceback.format_exc()
        return ConversationHandler.END


def second_answer(bot, update):
    user_hit = UserHits.select().where(UserHits.user_id == update.message.from_user.id)
    if user_hit.count() == 0:
        print 'cant find user id'
        return ConversationHandler.END

    user_hit = user_hit.get()
    user_text = update.message.text

    result, error_message = _check_recognition_correct(user_hit, user_text, 1)
    if result:
        blank, answer = generate_image()
        summ_a = random.randrange(100, 999)
        summ_b = random.randrange(100, 999)
        user_hit.key_2 = str(answer.values())
        user_hit.start_time_2 = datetime.now()
        user_hit.check_2 = summ_a + summ_b
        user_hit.save()

        filename = 'temp/' + str(random.random()) + '.png'
        blank.save(filename)

        bot.sendMessage(update.message.chat_id,
                    text='correct, do it one more time, please! summ = %d + %d' % (summ_a, summ_b))
        bot.sendPhoto(update.message.chat_id, photo=open(filename, 'rb'))
        os.remove(filename)
        return STEP_FINISH
    else:
        bot.sendMessage(update.message.chat_id,
                    text=error_message)
        return ConversationHandler.END


def finish(bot, update):
    user_hit = UserHits.select().where(UserHits.user_id == update.message.from_user.id)
    if user_hit.count() == 0:
        print 'cant find user id'
        return ConversationHandler.END

    user_hit = user_hit.get()
    user_text = update.message.text
    result, error_message = _check_recognition_correct(user_hit, user_text, 2)
    print 'result', result, error_message
    if result:
        bot.sendMessage(update.message.chat_id,
                    text='nice, take your flag: ' + FLAG)
    else:
        bot.sendMessage(update.message.chat_id,
                    text=error_message)

    return ConversationHandler.END


def cancel(bot, update):
    bot.sendMessage(update.message.chat_id,
                    text='Bye! I hope we can talk again some day.')

    return ConversationHandler.END


def error(bot, update, error):
    print('Update "%s" caused error "%s"' % (update, error))


def main():
    updater = Updater('263126590:AAEraIaYclajt16v7Wm35GX4msh5HM0ecns')
    dp = updater.dispatcher
    conv_handler = ConversationHandler(
        entry_points=[CommandHandler('start', start)],

        states={
            STEP_SECOND_IMAGE: [MessageHandler([Filters.text], second_answer)],
            STEP_FINISH: [MessageHandler([Filters.text], finish)],
        },

        fallbacks=[CommandHandler('cancel', cancel)]
    )

    dp.add_handler(conv_handler)
    dp.add_error_handler(error)
    updater.start_polling()
    updater.idle()


QUAD = 1
CIRCLE = 2
TRIANGLE = 3
def generate_image():
    blank = Image.open('images/blank.png')
    quad = Image.open('images/quad.png')
    circle = Image.open('images/circle.png')
    triangle = Image.open('images/triangle.png')
    images = {
        QUAD: quad,
        CIRCLE: circle,
        TRIANGLE: triangle
    }

    answer = {
        QUAD: 0,
        CIRCLE: 0,
        TRIANGLE: 0,
    }

    images_count = random.randint(5, 15)
    images_matrix = [random.randint(1, 3) for i in range(images_count)] + [0 for i in range(25-images_count)]
    random.shuffle(images_matrix)
    images_matrix = [images_matrix[i::5] for i in range(5)]

    for i in range(5):
        for g in range(5):
            if images_matrix[i][g]:
                image_id = images_matrix[i][g]
                image = images[image_id]
                blank.paste(image, (i*40, g*40, i*40+40, g*40+40))
                answer[image_id] += 1

    return blank, answer


def number_from_text(text, rex):
    result = re.findall(rex, text)
    if len(result):
        return int(result[0])
    else:
        return 0


def _check_recognition_correct(user_hit, user_text, step):
    print 'step ' + str(step) + ' obtain ' + user_text
    if not user_hit.check_summ(step, re.findall('(\d+)', user_text)[-1]):
        return False, 'check summ error! See a + b in message!'

    if not user_hit.check_time(step):
        return False, 'timeout error! limit is only 3 seconds O_o'

    answer_values = user_hit.get_key(step)[1:-1].split(',')
    answer_values = [int(a.strip()) for a in answer_values]
    answer = {
        QUAD: answer_values[0],
        CIRCLE: answer_values[1],
        TRIANGLE: answer_values[2]
    }

    user_answer = {
        QUAD: number_from_text(user_text, '(\d+) quad'),
        CIRCLE: number_from_text(user_text, '(\d+) circle'),
        TRIANGLE: number_from_text(user_text, '(\d+) triangle')
    }

    print 'correct:', answer
    print 'user:', user_answer

    return (user_answer[QUAD] == answer[QUAD] and
        user_answer[CIRCLE] == answer[CIRCLE] and
        user_answer[TRIANGLE] == answer[TRIANGLE]), ''


main()
