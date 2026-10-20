package br.com.maykon.voltadoalmoco;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.lang.reflect.Method;

/**
 * Tenta publicar a notificação como Live Update (Android 16 / API 36 ou superior).
 * Usa reflexão para não depender do SDK 36 na compilação. Se algo não existir ou falhar,
 * rejeita a chamada e o front desce para o próximo nível (notificação pública, depois padrão).
 */
@CapacitorPlugin(name = "LiveUpdate")
public class LiveUpdatePlugin extends Plugin {

    private static final String CHANNEL_ID = "volta-live";

    @PluginMethod
    public void show(PluginCall call) {
        try {
            if (Build.VERSION.SDK_INT < 36) {
                call.reject("Live Updates exige Android 16 ou superior");
                return;
            }
            Context ctx = getContext();
            NotificationManager nm = (NotificationManager) ctx.getSystemService(Context.NOTIFICATION_SERVICE);

            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, "Volta do almoço", NotificationManager.IMPORTANCE_DEFAULT);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            channel.setShowBadge(false);
            nm.createNotificationChannel(channel);

            Intent open = new Intent(ctx, MainActivity.class)
                    .setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent pi = PendingIntent.getActivity(
                    ctx, 0, open, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

            Notification.Builder b = new Notification.Builder(ctx, CHANNEL_ID)
                    .setSmallIcon(ctx.getApplicationInfo().icon)
                    .setContentTitle(call.getString("title", ""))
                    .setContentText(call.getString("body", ""))
                    .setOngoing(true)
                    .setOnlyAlertOnce(true)
                    .setVisibility(Notification.VISIBILITY_PUBLIC)
                    .setContentIntent(pi);

            // API 36: pedido de promoção (obrigatório) e texto curto da barra de status (opcional).
            Method promote = Notification.Builder.class.getMethod("setRequestPromotedOngoing", boolean.class);
            promote.invoke(b, true);
            String shortText = call.getString("shortText");
            if (shortText != null) {
                try {
                    Method sct = Notification.Builder.class.getMethod("setShortCriticalText", String.class);
                    sct.invoke(b, shortText);
                } catch (Throwable ignored) {
                    // opcional
                }
            }

            nm.notify(call.getInt("id", 1), b.build());
            call.resolve(new JSObject());
        } catch (Throwable t) {
            call.reject("Live Update falhou: " + t);
        }
    }

    @PluginMethod
    public void cancel(PluginCall call) {
        try {
            NotificationManager nm = (NotificationManager) getContext().getSystemService(Context.NOTIFICATION_SERVICE);
            nm.cancel(call.getInt("id", 1));
            call.resolve(new JSObject());
        } catch (Throwable t) {
            call.reject("Cancelar falhou: " + t);
        }
    }
}
