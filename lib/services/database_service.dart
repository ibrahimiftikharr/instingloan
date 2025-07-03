import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> connectWallet(String walletId, double initialBalance) async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();

    if (doc.exists && doc.data()?['walletId'] != null) {
      throw Exception('Wallet is already connected.');
    }
    //making sure wallet id is unique
    final existingWallet = await _firestore.collection('users')
        .where('walletId', isEqualTo: walletId)
        .limit(1)
        .get();

    if (existingWallet.docs.isNotEmpty) {
      throw Exception('Wallet ID already exists. Please use a different wallet ID.');
    }
    if (initialBalance <= 0) {
      throw Exception('Initial balance should be above 0.');
    }

    await _firestore.collection('users').doc(currentUserId).set({
      'walletId': walletId,
      'walletBalance': FieldValue.increment(initialBalance),
    }, SetOptions(merge: true));

    await recordTransaction(initialBalance, 'In', 'Wallet Initialization');
  }

  Future<void> depositToWallet(double amount) async {
    await _firestore.collection('users').doc(currentUserId).set({
      'walletBalance': FieldValue.increment(amount),
    }, SetOptions(merge: true));

    await recordTransaction(amount, 'In', 'Deposit');
  }

  Future<void> withdrawFromWallet(double amount, String toWalletId) async {
    final usersRef = _firestore.collection('users');
    final senderDoc = await usersRef.doc(currentUserId).get();

    if (senderDoc.exists && senderDoc.data()?['walletId'] == toWalletId) {
      throw Exception('Cannot send money to your own wallet.');
    }

    await usersRef.doc(currentUserId).set({
      'walletBalance': FieldValue.increment(-amount),
    }, SetOptions(merge: true));

    final querySnapshot = await usersRef
        .where('walletId', isEqualTo: toWalletId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final recipientRef = querySnapshot.docs.first.reference;
      await recipientRef.set({
        'walletBalance': FieldValue.increment(amount),
      }, SetOptions(merge: true));

      await recordTransaction(amount, 'Out', 'Transfer to $toWalletId');
    } else {
      throw Exception('Recipient wallet not found');
    }
  }

  Future<String> getWalletBalance() async {
    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    if (userDoc.exists && userDoc.data()?['walletBalance'] != null) {
      return userDoc.data()!['walletBalance'].toString();
    } else {
      throw Exception('Wallet not connected or balance not found.');
    }
  }

  Future<Map<String, dynamic>> getWalletDetails() async {
    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    return userDoc.data()!;
  }

  Future<void> recordTransaction(double amount, String direction, String purpose) async {
    await _firestore.collection('transactions').add({
      'userId': currentUserId,
      'amount': amount,
      'direction': direction,
      'purpose': purpose,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final transactions = await _firestore.collection('transactions')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .get();
    return transactions.docs.map((doc) => doc.data()).toList();
  }

  Future<void> deleteWallet() async {
    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final walletId = userDoc.data()?['walletId'];

    if (walletId == null) {
      throw Exception('No wallet connected to delete.');
    }

    // Check if this wallet is referenced in any loan repayments
    final loansWithWallet = await _firestore
        .collection('loans')
        .where('walletAddress', isEqualTo: walletId)
        .limit(1)
        .get();

    if (loansWithWallet.docs.isNotEmpty) {
      throw Exception('Cannot delete wallet: it is connected to loan repayments.');
    }

    await _firestore.collection('users').doc(currentUserId).update({
      'walletId': FieldValue.delete(),
      'walletBalance': FieldValue.delete(),
    });
  }

  Future<String> createLoanApplication(String loanName, double loanAmount, int loanPeriod, double interestRate) async {

    if (loanAmount <= 0) throw Exception('Loan amount must be greater than zero.');

    final walletId = (await _firestore.collection('users').doc(currentUserId).get()).data()?['walletId'];
    if (walletId == null || walletId.isEmpty) {
      throw Exception('Wallet not connected. Please connect your wallet first.');
    }

    final totalToBePaidBack = loanAmount + (loanAmount * interestRate / 100);
    final monthlyPayment = totalToBePaidBack / loanPeriod;

    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final walletAddress = userDoc.data()?['walletId'] ?? 'N/A';

    final loanRef = await _firestore.collection('loans').add({
      'borrowerId': currentUserId,
      'loanName': loanName,
      'loanAmount': loanAmount,
      'loanPeriod': loanPeriod,
      'interestRate': interestRate,
      'monthlyPayment': monthlyPayment,
      'totalToBePaidBack': totalToBePaidBack,
      'status': 'pending',
      'agreementDate': DateTime.now(),
      'walletAddress': walletAddress,
      'amountRepaid': 0.0,
    });

    await loanRef.update({'loanId': loanRef.id});
    return loanRef.id;
  }

  Future<void> pledgeInvestment(double amount) async {
    if (amount <= 0) throw Exception('Investment amount must be greater than zero.');
    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    if (userDoc.data()?['walletId'] == null) throw Exception('Wallet not connected.');
    if (userDoc.data()?['walletBalance'] < amount) throw Exception('Insufficient balance.');

    await _firestore.collection('investmentPool').add({
      'investorId': currentUserId,
      'totalInvested': amount,
      'totalPaidBack': 0,
      'totalProfit': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(currentUserId).update({
      'walletBalance': FieldValue.increment(-amount),
    });

    await recordTransaction(amount, 'Out', 'Investment in loans pool');
  }

  Future<void> issueAllPendingLoans() async {
    final loanDocs = await _firestore.collection('loans').where('status', isEqualTo: 'pending').get();
    final investorDocs = await _firestore.collection('investmentPool').get();

    double totalAvailable = investorDocs.docs.fold(0.0, (sum, doc) => sum + (doc.data()['totalInvested'] as num).toDouble());

    for (var loanDoc in loanDocs.docs) {
      final data = loanDoc.data();
      final loanAmount = (data['loanAmount'] as num).toDouble();

      if (totalAvailable >= loanAmount) {
        totalAvailable -= loanAmount;

        await _firestore.runTransaction((txn) async {
          txn.update(loanDoc.reference, {'status': 'approved'});
          txn.update(_firestore.collection('users').doc(data['borrowerId']), {
            'walletBalance': FieldValue.increment(loanAmount),
          });
          txn.set(_firestore.collection('transactions').doc(), {
            'userId': data['borrowerId'],
            'amount': loanAmount,
            'direction': 'In',
            'purpose': 'Loan Issued for ${data['loanName']}',
            'timestamp': FieldValue.serverTimestamp(),
          });
        });
      }
    }
  }

  Future<void> makeRepayment(String loanId, double monthlyPayment) async {
    final loanDoc = await _firestore.collection('loans').doc(loanId).get();
    if (!loanDoc.exists) throw Exception('Loan not found');

    final loanData = loanDoc.data()!;
    if (loanData['status'] == 'completed') throw Exception('Loan already completed');

    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final walletBalance = (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
    if (walletBalance < monthlyPayment) throw Exception('Insufficient balance');

    await _firestore.collection('users').doc(currentUserId).update({
      'walletBalance': FieldValue.increment(-monthlyPayment),
    });

    final newTotalRepaid = (loanData['amountRepaid'] as num).toDouble() + monthlyPayment;
    final totalToBePaid = (loanData['totalToBePaidBack'] as num).toDouble();
    final newStatus = newTotalRepaid >= totalToBePaid ? 'completed' : loanData['status'];

    await _firestore.collection('loans').doc(loanId).update({
      'amountRepaid': newTotalRepaid,
      'status': newStatus,
    });

    await recordTransaction(monthlyPayment, 'Out', 'Loan Repayment for ${loanData['loanName']}');

    final investorDocs = await _firestore.collection('investmentPool').get();
    final totalInvested = investorDocs.docs.fold(0.0, (sum, doc) => sum + (doc.data()['totalInvested'] as num).toDouble());
    if (totalInvested == 0.0) return;

    // Calculate interest portion for this repayment
    final loanAmount = (loanData['loanAmount'] as num).toDouble();
    final totalInterest = ((loanData['interestRate'] as num).toDouble() / 100.0) * loanAmount;
    final loanPeriod = (loanData['loanPeriod'] as int);
    final interestPerRepayment = totalInterest / loanPeriod;

    for (var doc in investorDocs.docs) {
      final data = doc.data();
      final investorId = data['investorId'];
      final investedAmount = (data['totalInvested'] as num).toDouble();
      final share = (investedAmount / totalInvested) * monthlyPayment;

      // Only the interest portion is profit
      final profitShare = (investedAmount / totalInvested) * interestPerRepayment;

      await _firestore.collection('users').doc(investorId).update({
        'walletBalance': FieldValue.increment(share),
      });

      await doc.reference.update({
        'totalPaidBack': FieldValue.increment(share),
        'totalProfit': FieldValue.increment(profitShare),
      });

      await _firestore.collection('transactions').add({
        'userId': investorId,
        'amount': share,
        'direction': 'In',
        'purpose': 'Loan repayment earnings from ${loanData['loanName']}',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('transactions').add({
        'userId': investorId,
        'amount': share*0.025,
        'direction': 'In',
        'purpose': 'Monthly profit from ${loanData['loanName']}',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Map<String, dynamic>> getLoanDetails(String loanId) async {
    final loanDoc = await _firestore.collection('loans').doc(loanId).get();
    if (!loanDoc.exists) throw Exception('Loan not found');
    final data = loanDoc.data()!;
    data['loanId'] = loanDoc.id;
    return data;
  }

  Future<List<Map<String, dynamic>>> getBorrowerLoans() async {
    final loans = await _firestore.collection('loans')
        .where('borrowerId', isEqualTo: currentUserId).get();
    return loans.docs.map((doc) {
      final data = doc.data();
      data['loanId'] = doc.id;
      return data;
    }).toList();
  }

  //get totalInvested and totalPaidBack for investor
  Future<Map<String, double>> getInvestorStats() async {
    final investment = await _firestore.collection('investmentPool')
        .where('investorId', isEqualTo: currentUserId).limit(1).get();

    double totalInvested = 0.0;
    double totalPaidBack = 0.0;
    double totalProfit = 0.0;

    if (investment.docs.isNotEmpty) {
      final data = investment.docs.first.data();
      totalInvested = (data['totalInvested'] as num).toDouble() ?? 0.0;
      totalPaidBack = (data['totalPaidBack'] as num).toDouble() ?? 0.0;
      totalProfit = (data['totalProfit'] as num).toDouble() ?? 0.0;
    }

    return {
      'totalInvested': totalInvested,
      'totalPaidBack': totalPaidBack,
      'totalProfit': totalProfit,
    };
  }

}