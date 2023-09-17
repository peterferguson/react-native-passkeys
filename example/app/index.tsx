import { StyleSheet, Text, View } from 'react-native';

import * as ExpoPasskeys from 'expo-passkeys';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{ExpoPasskeys.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fccefe',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
