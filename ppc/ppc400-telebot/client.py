# -*- coding: utf-8 -*-
"""
Simplest way to just send a message.
Without complicated message receiving stuff.
"""
import json
from pytg.receiver import Receiver
from pytg.sender import Sender
from pytg.utils import coroutine


@coroutine
def example_function(receiver, sender):
    try:
        while True:
            msg = (yield)
            print('Full dump: {array}'.format(array=str(msg)))
            if 'sender' in msg and msg['sender']['name'] == 'KCTFBot':
                if 'media' in msg and msg['media']['type'] == 'photo':
                    file = sender.load_photo(msg['id'])
    except KeyboardInterrupt:
        receiver.stop()
        print("Exiting")


def main():
    sender = Sender("127.0.0.1", 4458)
    print sender.msg("KCTFBot", u"/start")
    receiver = Receiver(port=4458)
    receiver.start()
    receiver.message(example_function(
        receiver, sender))


if __name__ == '__main__':
    main()
