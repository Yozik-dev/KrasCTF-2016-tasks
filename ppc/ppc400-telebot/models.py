from datetime import datetime, timedelta
from peewee import *


class BaseModel(Model):
    class Meta:
        database = SqliteDatabase('db.db')


class UserHits(BaseModel):
    user_id = BigIntegerField()
    user_name = CharField()
    key_1 = CharField()
    start_time_1 = DateTimeField()
    pass_1 = BooleanField(default=False)
    check_1 = IntegerField()
    key_2 = CharField(null=True)
    start_time_2 = DateTimeField(null=True)
    pass_2 = BooleanField(default=False)
    check_2 = IntegerField(null=True)

    def get_key(self, step):
        if step == 1:
            return self.key_1
        elif step == 2:
            return self.key_2
        else:
            return ''

    def check_time(self, step):
        if step == 1:
            delta = datetime.now() - self.start_time_1
            print 'answer time:', delta
            return delta < timedelta(seconds=3)
        elif step == 2:
            delta = datetime.now() - self.start_time_2
            print 'answer time:', delta
            return delta < timedelta(seconds=3)
        else:
            return False

    def check_summ(self, step, summ):
        if step == 1:
            print 'summ need', self.check_1, 'get', summ
            return self.check_1 == int(summ)
        elif step == 2:
            return self.check_2 == int(summ)
        else:
            return False


if __name__ == '__main__':
    UserHits.create_table()
