import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface User {
  id: number
  username: string
  name: string
  email: string
  roles: string[]
}

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const token = ref<string>('')
  
  const isAuthenticated = computed(() => !!token.value)
  
  const setUser = (userData: User) => {
    user.value = userData
  }
  
  const setToken = (tokenValue: string) => {
    token.value = tokenValue
  }
  
  const logout = () => {
    user.value = null
    token.value = ''
  }
  
  return {
    user,
    token,
    isAuthenticated,
    setUser,
    setToken,
    logout
  }
}, {
  persist: true
})