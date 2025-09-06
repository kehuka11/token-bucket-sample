import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // 20RPSでリクエストを送信
  stages: [
    { duration: '10s', target: 5 },    // 10秒で20RPSまで増加
    { duration: '30s', target: 5 },    // 30秒間20RPSを維持
    { duration: '10s', target: 0 },     // 10秒で0RPSまで減少
  ],
};

export default function () {
  const url = 'http://localhost:8080/api/bucket4j/light/status';
  
  // GETリクエストを送信
  const response = http.get(url);
  
  // HTTPステータスコードをログに表示
  console.log(`HTTP Status: ${response.status} - ${response.status_text}`);
  
  // レスポンスの詳細情報も表示（エラー時のみ）
  if (response.status !== 200) {
    console.log(`Error Response: ${response.body}`);
  }
  
  // レート制限の動作を確認するため、少し待機
  sleep(0.05); // 50ms待機（20RPS = 50ms間隔）
} 