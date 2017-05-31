#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QWidget>
#include <QVBoxLayout>
#include <QGridLayout>
#include <QHBoxLayout>
#include <QLineEdit>
#include <QLabel>
#include <QPushButton>
#include <QTabWidget>
#include <QMessageBox>
#include <QTableWidget>
#include <QDateTimeEdit>
#include <QComboBox>
#include <visitor.h>

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
private:
    QWidget *loginMainWindow;
    QVBoxLayout *loginMainLayout;
    QGridLayout *loginTopLayout;
    QHBoxLayout *loginBottomLayout;
    QLineEdit *loginIDEdit;
    QLineEdit *loginNameEdit;
    QLineEdit *loginPasswordEdit;
    QLabel *loginIDLabel;
    QLabel *loginNameLabel;
    QLabel *loginPasswordLabel;
    QPushButton *loginVisitorButton;
    QPushButton *loginAdminButton;

    QTabWidget *adminTab;

    QWidget *adminFlightWindow;
    QLineEdit *adminFlightNoEdit;
    QLineEdit *adminFlightStartEdit;
    QLineEdit *adminFlightEndEdit;
    QDateTimeEdit *adminFlightTimeEdit;
    QLabel *adminFlightNoLabel;
    QLabel *adminFlightStartLabel;
    QLabel *adminFlightEndLabel;
    QLabel *adminFlightTimeLabel;
    QPushButton *adminFlightAddButton;
    QPushButton *adminFlightDelButton;
    QTableWidget *adminFlightTable;
    QHBoxLayout *adminFlightTopLayout;
    QHBoxLayout *adminFlightBottomLayout;
    QVBoxLayout *adminFlightMainLayout;

    QWidget *adminSeatWindow;
    QLineEdit *adminSeatFnoEdit;
    QLineEdit *adminSeatSnoEdit;
    QComboBox *adminSeatTypeEdit;
    QLineEdit *adminSeatPriceEdit;
    QLabel *adminSeatFnoLabel;
    QLabel *adminSeatSnoLabel;
    QLabel *adminSeatTypeLabel;
    QLabel *adminSeatPriceLabel;
    QPushButton *adminSeatAddButton;
    QPushButton *adminSeatDelButton;
    QTableWidget *adminSeatTable;
    QHBoxLayout *adminSeatTopLayout;
    QHBoxLayout *adminSeatBottomLayout;
    QVBoxLayout *adminSeatMainLayout;

    QTabWidget *visitorTab;

    QWidget *visPurchaseWindow;
    QLineEdit *visPurchaseStartEdit;
    QLineEdit *visPurchaseEndEdit;
    QLabel *visPurchaseStartLabel;
    QLabel *visPurchaseEndLabel;
    QTableWidget *visPurchaseTable;
    QPushButton *visPurchaseButton;
    QHBoxLayout *visPurchaseTopLayout;
    QHBoxLayout *visPurchaseBottomLayout;
    QVBoxLayout *visPurchaseMainLayout;

    QWidget *visFetchWindow;
    QPushButton *visFetchButton;

    QWidget *visCancelWindow;
    QPushButton *visCancelButton;

    QWidget *visBillingWindow;

    QWidget *visQueryWindow;
    QPushButton *visQueryButton;

    Visitor *visitor;

    void createLoginView(void);

    MainWindow *createAdminView(void);
    MainWindow *createAdminFlightWindow(void);
    MainWindow *createAdminSeatWindow(void);

    MainWindow *createVisitorView(void);
    MainWindow *createVisPurchaseWindow(void);
    MainWindow *createVisFetchWindow(void);
    MainWindow *createVisCancelWindow(void);
    MainWindow *createVisBillingWindow(void);
    MainWindow *createVisQueryWindow(void);

    void adminRenderFlightTable(void);
    void adminRenderSeatTable(void);

    inline void showMsgBox(const QString &icon, const QString &title = "Error", const QString &text = "Error") const {
        QMessageBox errorMsg;
        errorMsg.setIconPixmap(QPixmap(icon).scaled(20, 20));
        errorMsg.setWindowTitle(title);
        errorMsg.setText(text);
        errorMsg.exec();
    }

private slots:
    void onLoginVisitorButton(void);
    void onLoginAdminButton(void);

    void onAdminFlightAddButton(void);
    void onAdminFlightDelButton(void);

    void onAdminSeatAddButton(void);
    void onAdminSeatDelButton(void);

    void onVisPurchaseButton(void);
};

#endif // MAINWINDOW_H
