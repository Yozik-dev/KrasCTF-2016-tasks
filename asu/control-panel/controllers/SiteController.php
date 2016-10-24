<?php

namespace app\controllers;

use Yii;
use yii\web\Controller;
use app\models\LoginForm;

class SiteController extends Controller
{
    public function actions()
    {
        return [
            'error' => [
                'class' => 'yii\web\ErrorAction',
            ],
        ];
    }

    /**
     * Displays homepage.
     * @return string
     */
    public function actionIndex()
    {
        if (!Yii::$app->user->isGuest) {
            return $this->redirect(['/control-panel']);
        }
        $model = new LoginForm();
        return $this->render('morze', ['model' => $model]);
    }

    /**
     * Login action.
     * @return string
     */
    public function actionMorze()
    {
        if (!Yii::$app->user->isGuest) {
            return $this->redirect(['/control-panel']);
        }

        $model = new LoginForm();
        if ($model->load(Yii::$app->request->post()) && $model->login()) {
            return $this->redirect(['/control-panel']);
        }
        return $this->render('morze', [
            'model' => $model,
        ]);
    }

    /**
     * Cosmos action.
     * @return string
     */
    public function actionPanel()
    {
        if (Yii::$app->user->isGuest) {
            return $this->redirect(['/']);
        }
        if(file_exists(Yii::getAlias('@runtime') . '/data.dat')) {
            $data = file_get_contents(Yii::getAlias('@runtime') . '/data.dat');
        } else {
            $data = 1;
        }
        return $this->render('panel', ['stage' => intval($data)]);
    }

    public function actionChangeStage($stage, $pass)
    {
        Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
        if(sha1($stage . 'psevd0Solb') == $pass && $stage > 0 && $stage < 5){
            file_put_contents(Yii::getAlias('@runtime') . '/data.dat', $stage);
            return ['status' => true];
        }
        return ['status' => false];
    }

}
