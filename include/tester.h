#ifndef TESTER_H
#define TESTER_H

using namespace std;

void meas(auto var){
    cout << var << endl;
}

void meas_oc(auto var){
    meas(var);
    exit(0);
}

#endif