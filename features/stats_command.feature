Feature: "net_tester stats" コマンド

  NetTester ユーザは、"net_tester stats ホスト名" コマンドで
  仮想ホストの送受信パケット数を表示できる。

  実行例:
  $ net_tester stats host1
  Packets sent:
    host2 -> host1 = 1 packet
  Packets received:
    host1 -> host2 = 1 packet

  Background:
    Given テスト対象のネットワークにイーサネットスイッチが 1 台
    And NetTester でテストホスト 2 台を起動
    And DPID が 0xdef の NetTester 物理スイッチ
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             1 |           1 |
      |             2 |           2 |
    And NetTester 仮想スイッチと物理スイッチを次のように接続:
      | Virtual Port | Physical Port |
      |            3 |             3 |
    And 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |

  Scenario: host1 の送受信パケット数を "net_tester stats host1" で表示
    When 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    And コマンド `net_tester stats host1` の実行に成功
    Then コマンド "net_tester stats host1" の出力は次のとおり:
      """
      Packets sent:
        host1 -> host2 = 1 packet
      Packets received:
        host2 -> host1 = 1 packet
      """

  Scenario: パケットを送受信せずに "net_tester stats host1"
    When コマンド `net_tester stats host1` の実行に成功
    Then コマンドの出力はなし

  Scenario: ホスト名を指定せず "net_tester stats"
    When コマンド `net_tester stats` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "host is required" を含む

  Scenario: 不正なホスト名を指定
    When コマンド `net_tester stats NO_SUCH_HOST` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "NO_SUCH_HOST: no such host" を含む

  Scenario: NetTester が起動していない状態で "net_tester stats host1"
    Given コマンド `net_tester kill` の実行に成功
    When コマンド `net_tester stats host1` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "NetTester is not running" を含む