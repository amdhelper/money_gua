#!/usr/bin/env python3
"""
测试 TTS 功能的脚本
"""
import subprocess
import os
import tempfile

def test_edge_tts():
    """测试 edge-tts 命令行工具"""
    print("测试 edge-tts 命令行工具...")
    
    # 检查本地 python_env 中的 edge-tts
    local_edge_tts = "./python_env/bin/edge-tts"
    if os.path.exists(local_edge_tts):
        print(f"✓ 找到本地 edge-tts: {local_edge_tts}")
        edge_tts_path = local_edge_tts
    else:
        # 检查系统路径中的 edge-tts
        try:
            result = subprocess.run(['which', 'edge-tts'], capture_output=True, text=True)
            if result.returncode == 0:
                edge_tts_path = result.stdout.strip()
                print(f"✓ 找到系统 edge-tts: {edge_tts_path}")
            else:
                print("✗ 未找到 edge-tts")
                return False
        except Exception as e:
            print(f"✗ 检查 edge-tts 时出错: {e}")
            return False
    
    # 测试语音合成
    test_text = "测试金钱卦应用的语音功能"
    with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as tmp_file:
        output_file = tmp_file.name
    
    try:
        print(f"正在合成语音: '{test_text}'")
        cmd = [
            edge_tts_path,
            '--text', test_text,
            '--voice', 'zh-CN-YunxiNeural',
            '--write-media', output_file
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
                print(f"✓ 语音合成成功，输出文件: {output_file}")
                print(f"  文件大小: {os.path.getsize(output_file)} 字节")
                
                # 尝试播放音频文件（如果有播放器的话）
                try:
                    subprocess.run(['paplay', output_file], timeout=10)
                    print("✓ 音频播放完成")
                except FileNotFoundError:
                    print("! 未找到 paplay，尝试其他播放器...")
                    try:
                        subprocess.run(['aplay', output_file], timeout=10)
                        print("✓ 音频播放完成")
                    except FileNotFoundError:
                        print("! 未找到音频播放器，但文件生成成功")
                except subprocess.TimeoutExpired:
                    print("! 播放超时")
                
                return True
            else:
                print("✗ 输出文件不存在或为空")
                return False
        else:
            print(f"✗ edge-tts 执行失败: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print("✗ edge-tts 执行超时")
        return False
    except Exception as e:
        print(f"✗ 执行过程中出错: {e}")
        return False
    finally:
        # 清理临时文件
        if os.path.exists(output_file):
            os.unlink(output_file)

def test_system_tts():
    """测试系统 TTS 功能"""
    print("\n测试系统 TTS 功能...")
    
    # 检查 espeak
    try:
        result = subprocess.run(['which', 'espeak'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✓ 找到 espeak")
            try:
                subprocess.run(['espeak', '-v', 'zh', '测试系统语音'], timeout=10)
                print("✓ espeak 测试完成")
                return True
            except Exception as e:
                print(f"✗ espeak 执行失败: {e}")
        else:
            print("! 未找到 espeak")
    except Exception as e:
        print(f"✗ 检查 espeak 时出错: {e}")
    
    # 检查 festival
    try:
        result = subprocess.run(['which', 'festival'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✓ 找到 festival")
            try:
                subprocess.run(['festival', '--tts'], input="Hello world", text=True, timeout=10)
                print("✓ festival 测试完成")
                return True
            except Exception as e:
                print(f"✗ festival 执行失败: {e}")
        else:
            print("! 未找到 festival")
    except Exception as e:
        print(f"✗ 检查 festival 时出错: {e}")
    
    return False

def check_audio_system():
    """检查音频系统"""
    print("\n检查音频系统...")
    
    # 检查 PulseAudio
    try:
        result = subprocess.run(['pulseaudio', '--check'], capture_output=True)
        if result.returncode == 0:
            print("✓ PulseAudio 正在运行")
        else:
            print("! PulseAudio 未运行")
    except FileNotFoundError:
        print("! 未找到 PulseAudio")
    except Exception as e:
        print(f"✗ 检查 PulseAudio 时出错: {e}")
    
    # 检查音频设备
    try:
        result = subprocess.run(['pactl', 'list', 'short', 'sinks'], capture_output=True, text=True)
        if result.returncode == 0 and result.stdout.strip():
            print("✓ 找到音频输出设备:")
            for line in result.stdout.strip().split('\n'):
                print(f"  {line}")
        else:
            print("! 未找到音频输出设备")
    except FileNotFoundError:
        print("! 未找到 pactl 命令")
    except Exception as e:
        print(f"✗ 检查音频设备时出错: {e}")

def main():
    print("=== 金钱卦应用 TTS 功能诊断 ===\n")
    
    # 切换到应用目录
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    check_audio_system()
    
    edge_tts_ok = test_edge_tts()
    system_tts_ok = test_system_tts()
    
    print("\n=== 诊断结果 ===")
    if edge_tts_ok:
        print("✓ edge-tts 功能正常")
    else:
        print("✗ edge-tts 功能异常")
    
    if system_tts_ok:
        print("✓ 系统 TTS 功能正常")
    else:
        print("✗ 系统 TTS 功能异常")
    
    if not edge_tts_ok and not system_tts_ok:
        print("\n建议:")
        print("1. 安装 edge-tts: pip install edge-tts")
        print("2. 安装系统 TTS: sudo apt install espeak espeak-data")
        print("3. 检查音频系统配置")

if __name__ == "__main__":
    main()